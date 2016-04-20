#include "Accounts/Accounts.h"
#import "LockMinderViewController.h"
#import "MBProgressHUD.h"
#import "Social/Social.h"
#import <EventKit/EventKit.h>
#import "LPReminderCell.h"
#define NSLog(LogContents, ...)                                                \
  NSLog((@"LPInterfaceBuilderExample: %s:%d " LogContents), __FUNCTION__,      \
        __LINE__, ##__VA_ARGS__)

@implementation LockMinderViewController

NSString *userPlaceHolder;

- (id)init {
  self = [super init];
  if (self) {
    _ibView = [[
        [NSBundle bundleWithPath:
                      @"/Library/Application Support/LockMinder"]
        loadNibNamed:@"LPReminderView"
               owner:self
             options:nil] objectAtIndex:0];
    [self setView:_ibView];
  }
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.delegate = self;
   UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  refreshControl.backgroundColor = [UIColor clearColor];
  refreshControl.tintColor = [UIColor whiteColor];
  [refreshControl addTarget:self
                     action:@selector(updateView)
           forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];


    
    [self.tableView registerNib: [UINib nibWithNibName: @"LPReminderCell" bundle: [NSBundle bundleWithPath:@"/Library/Application Support/LockMinder"]]forCellReuseIdentifier:@"Cell"];


  return self;
}

- (void)pageWillPresent {
  NSLog(@"pageWillPresent called!");
    [self updateView];

   
    
}
//Should use individual list?
-(BOOL)shouldUseIndividual{
    if (filePath == nil) {
        filePath = @"/Library/Application Support/LockMinder/settings.plist";
    }
    
    BOOL exists;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    exists = [fileManager fileExistsAtPath:filePath];
    if (exists == false) {
        return false;
    }else{
        NSMutableDictionary *plistdict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        return [[plistdict objectForKey:@"useLists"] boolValue];
        
    }
}
-(NSInteger)calulatePriority{
    if (filePath == nil) {
        filePath = @"/Library/Application Support/LockMinder/settings.plist";
    }
    
    BOOL exists;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    exists = [fileManager fileExistsAtPath:filePath];
    if (exists == false) {
        return 10;
    }else{
        NSMutableDictionary *plistdict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        return [[plistdict objectForKey:@"priority"] integerValue];
        
    }

}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"Made with <3 in Memphis, TN";
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

//If so, what list?
-(NSString *)fetchListTitle{
    if (filePath == nil) {
        filePath = @"/Library/Application Support/LockMinder/settings.plist";
    }
    

    NSMutableDictionary *plistdict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    return [plistdict objectForKey:@"list"];
    
    
}

-(void)updateView{
  //Check for store
    if(self.store == nil){
        self.store = [[EKEventStore alloc] init];
    }
   
    
    BOOL individual = [self shouldUseIndividual];


    @try {
        [self.store fetchRemindersMatchingPredicate:[self fetchPredicate: individual] completion:^(NSArray *completed) {
            self.events = [completed mutableCopy];
            
        }];
        
    } @catch (NSException *exception) {
        UILabel *error = [[UILabel alloc]initWithFrame: self.view.frame];
        error.text = @"Error fetching reminders, try again";
        error.textAlignment = NSTextAlignmentCenter;
        error.textColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundView = error;
    }
    [UIView transitionWithView:self.tableView
duration:0.35f
options:UIViewAnimationOptionTransitionCrossDissolve
animations:^(void)
    {
        
    [self.tableView reloadData];
        
    }
completion:nil];
    
   [self.refreshControl endRefreshing];
    

}
-(NSPredicate *)fetchPredicate: (BOOL) single{
    if(self.store == nil){
        self.store = [[EKEventStore alloc] init];
    }
    
    if (single == true){
        return [self.store predicateForIncompleteRemindersWithDueDateStarting: nil ending: nil calendars: nil];
    }else{
        NSString *constTitle = [self fetchListTitle];
        for (EKCalendar *calendar in [self.store calendarsForEntityType: EKEntityTypeReminder]) {
            if (calendar.title == constTitle) {
                return [self.store predicateForIncompleteRemindersWithDueDateStarting: nil ending: nil calendars: @[calendar]];
            }
        }
        
    }
   // return [self.store predicateForIncompleteRemindersWithDueDateStarting: nil ending: nil calendars: nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
         return self.events.count;
    }else{
         return self.completed.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  LPReminderCell *cell =
      [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.urgencyLabel.text = @"";
    cell.urgencyLabel.clipsToBounds = true;
    cell.urgencyLabel.layer.cornerRadius = cell.urgencyLabel.frame.size.width / 2;
    
        
    if (self.events.count != 0) {
    cell.urgencyLabel.backgroundColor = [UIColor clearColor];
    cell.urgencyLabel.layer.borderWidth = 2.0;
        
    EKReminder *evnt = self.events[indexPath.row];
    if (evnt.dueDateComponents != nil) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *date = [gregorianCalendar dateFromComponents:evnt.dueDateComponents];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        if ([[NSDate date] compare: date] == NSOrderedDescending) {
            NSLog(@"date1 is later than date2");
             cell.urgencyLabel.layer.borderColor = [[UIColor redColor] CGColor];
        } else if ([[NSDate date] compare: date] == NSOrderedAscending) {
            NSLog(@"date1 is earlier than date2");
             cell.urgencyLabel.layer.borderColor = [[UIColor greenColor] CGColor];
        } else {
            NSLog(@"dates are the same");
             cell.urgencyLabel.layer.borderColor = [[UIColor yellowColor] CGColor];
            
        }
        cell.urgencyLabel.backgroundColor = [UIColor clearColor];
        
        
        cell.dateLabel.text =  [formatter stringFromDate: date];
    }else{
        cell.dateLabel.text = @"No due date";
        cell.urgencyLabel.layer.borderColor = [[UIColor greenColor] CGColor];
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.titleLabel.text = evnt.title;
    }
  return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self shouldUseIndividual] == false) {
        return [self fetchListTitle];
    }else{
        return @"All items";
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView
    estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  // minimum size of your cell, it should be single line of label if you are not
  // clear min. then return UITableViewAutomaticDimension;
  return UITableViewAutomaticDimension;
}
- (void)pageDidPresent {
  NSLog(@"pageDidPresent called!");


    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(updateView)
                                   userInfo:nil
                                    repeats:NO];
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = 100.0;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 100.0;
}
- (void)pageWillDismiss {
  NSLog(@"pageWillDismiss called!");
}

- (void)pageDidDismiss {
  NSLog(@"pageDidDismiss called!");
}
/*- (void)viewDidAppear:(BOOL)animated{
    [self updateView];
    [super viewDidAppear: true];
}*/
-(void)showHud{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeCustomView;
    
    
    UIImage *image = [[UIImage
                       imageWithContentsOfFile:@"/Library/Application "
                       @"Support/LockMinder/Contents/"
                       @"Resources/check.png"]
                      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView =
    [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 100, 100);
    [imageView setTintColor:[UIColor whiteColor]];
    self.hud.customView = imageView;
    self.hud.labelText = NSLocalizedString(@"Completed!", @"HUD done title");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath: indexPath animated: true];
    LPReminderCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    cell.urgencyLabel.backgroundColor = [UIColor colorWithCGColor: cell.urgencyLabel.layer.borderColor];
    
    EKReminder *event = self.events[indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self markReminderComplete: event];
        [self.events removeObjectAtIndex: indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        });
    [self showHud];
        [self.hud hide:true afterDelay:1.0f];
    
}
-(void)markReminderComplete: (EKReminder *)event{
    event.completed = true;
    
    [self.store saveReminder: event commit: true error: nil];
    

}
- (CGFloat)idleTimerInterval {
  return 60;
}

- (BOOL)isTimeEnabled {
  return 1;
}

- (CGFloat)backgroundAlpha {
  return 0.6;
}

- (NSInteger)priority {
    NSInteger priority = [self calulatePriority];
    return priority;
}
@end
