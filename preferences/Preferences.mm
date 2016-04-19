#import <Preferences/Preferences.h>
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>
@interface PreferencesListController: PSListController <UITableViewDataSource, UITableViewDelegate> {
    
}
@property(strong, nonatomic) NSMutableArray *reminders;
@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *completed;
@end

@implementation PreferencesListController
/*- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Preferences" target:self] retain];
	}
	return _specifiers;
}*/

-(void)viewDidLoad{
    [super viewDidLoad];
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
    
    if(self.store == nil){
        self.store = [[EKEventStore alloc] init];
    }
    NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeEvent];

    for (EKCalendar *r in calendars) {
        [self.reminders addObject: r.title];
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.view = tableView;
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else{
        return [self.reminders count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if(indexPath.section == 0){
    // Configure the cell.
    cell.textLabel.text = @"Thanks ryan!";
    return cell;
    }else{
        cell.textLabel.text = self.reminders[indexPath.row];
         return cell;
    }
}



@end

// vim:ft=objc
