#include "Accounts/Accounts.h"
#import "LockMinderViewController.h"
#import "MBProgressHUD.h"
#import "Social/Social.h"
#import <EventKit/EventKit.h>
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
                      @"/Library/Application Support/LPInterfaceBuilderExample"]
        loadNibNamed:@"LPTwitterView"
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
    [self.tableView reloadData];
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
  UITableViewCell *cell =
      [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"Cell"];
  }
    EKReminder *evnt = self.events[indexPath.row];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorianCalendar dateFromComponents:evnt.dueDateComponents];
    
    NSString * str = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    str = [str stringByAppendingString: [formatter stringFromDate:date]];
    str = [str stringByAppendingString:@" - "];
    str = [str stringByAppendingString:evnt.title];
    cell.textLabel.text = str;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
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
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}
- (void)pageWillDismiss {
  NSLog(@"pageWillDismiss called!");
}

- (void)pageDidDismiss {
  NSLog(@"pageDidDismiss called!");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
   
    EKReminder *event = self.events[indexPath.row];
    event.completed = true;
    [self.store saveReminder: event commit: true error: nil];
    [self.events removeObjectAtIndex: indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
  

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
