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
                     action:@selector(pageWillPresent)
           forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];

  return self;
}

- (void)pageWillPresent {
  NSLog(@"pageWillPresent called!");

    EKEventStore *store = [[EKEventStore alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar dateBySettingHour:0  minute:0  second:0  ofDate:[NSDate date] options:0];
    NSDate *endDate   = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:0];
    
    NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate
                                                            endDate:endDate
                                                          calendars:nil];
    
    self.events = [store eventsMatchingPredicate:predicate];
    [self.tableView reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.events.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"Cell"];
  }

  return cell;
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
