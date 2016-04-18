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

   
    
}
-(void)updateView{
  
    if(self.store == nil){
        self.store = [[EKEventStore alloc] init];
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES] ;
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSPredicate *predicate = [self.store predicateForIncompleteRemindersWithDueDateStarting: nil ending: nil calendars: nil];
    
    NSPredicate *completePredicate = [self.store predicateForCompletedRemindersWithCompletionDateStarting: nil ending: nil calendars: nil];
    
    [self.store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *completed) {
        self.events = [[completed sortedArrayUsingDescriptors: sortDescriptors] mutableCopy];
        
    }];
    [self.store fetchRemindersMatchingPredicate:completePredicate completion:^(NSArray *incompleted) {
        self.completed = [[incompleted sortedArrayUsingDescriptors: sortDescriptors] mutableCopy];
        
    }];
    
   [self.refreshControl endRefreshing];
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];

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
    cell.urgencyLabel.layer.cornerRadius = 5.0f;
    
    EKReminder *evnt = self.events[indexPath.row];
    if (evnt.dueDateComponents != nil) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *date = [gregorianCalendar dateFromComponents:evnt.dueDateComponents];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        if ([[NSDate date] compare: date] == NSOrderedDescending) {
            NSLog(@"date1 is later than date2");
             cell.urgencyLabel.backgroundColor = [UIColor redColor];
        } else if ([[NSDate date] compare: date] == NSOrderedAscending) {
            NSLog(@"date1 is earlier than date2");
             cell.urgencyLabel.backgroundColor = [UIColor greenColor];
        } else {
            NSLog(@"dates are the same");
             cell.urgencyLabel.backgroundColor = [UIColor yellowColor];
            
        }
        
        
        cell.dateLabel.text =  [formatter stringFromDate: date];
    }else{
        cell.dateLabel.text = @"No due date";
        cell.urgencyLabel.backgroundColor = [UIColor greenColor];
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.titleLabel.text = evnt.title;
  return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Incomplete";
}

- (CGFloat)tableView:(UITableView *)tableView
    estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  // minimum size of your cell, it should be single line of label if you are not
  // clear min. then return UITableViewAutomaticDimension;
  return UITableViewAutomaticDimension;
}
- (void)pageDidPresent {
  NSLog(@"pageDidPresent called!");
     [self updateView];
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
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
- (void)viewDidAppear:(BOOL)animated{
    [self updateView];
    [super viewDidAppear: true];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
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
    EKReminder *event = self.events[indexPath.row];
    event.completed = true;
    [self.store saveReminder: event commit: true error: nil];
    [self.events removeObjectAtIndex: indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
  
     [self.hud hide:true afterDelay:1.0f];
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
  return 10;
}
@end
