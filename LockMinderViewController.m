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

    [self updateView];
    
}
-(void)updateView{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    NSPredicate *predicate = [store predicateForIncompleteRemindersWithDueDateStarting: nil ending: nil calendars: nil];
    
    NSPredicate *completePredicate = [store predicateForCompletedRemindersWithCompletionDateStarting: nil ending: nil calendars: nil];
    
    [store fetchRemindersMatchingPredicate:predicate completion:^(NSArray *completed) {
        self.events = [completed mutableCopy];
        
    }];
    [store fetchRemindersMatchingPredicate:completePredicate completion:^(NSArray *incompleted) {
        self.completed = [incompleted mutableCopy];
        
    }];
    [self.tableView reloadData];
   [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 2;
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
    if(indexPath.section == 0){
        EKEvent * evnt = self.events[indexPath.row];
        cell.textLabel.text = evnt.title;
    }else{
        EKEvent * evnt = self.completed[indexPath.row];
        cell.textLabel.text = evnt.title;
    }

    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
  return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1){

        return @"Completed";
    }else{
        return @"Incomplete";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
    estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  // minimum size of your cell, it should be single line of label if you are not
  // clear min. then return UITableViewAutomaticDimension;
  return UITableViewAutomaticDimension;
}
- (void)pageDidPresent {
  NSLog(@"pageDidPresent called!");
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
