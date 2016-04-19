#import <Preferences/Preferences.h>
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>
@interface PreferencesListController: PSViewController <UITableViewDataSource, UITableViewDelegate> {

    NSString *_path;
    NSArray *_paths;
    NSMutableArray *_enabledPaths;
    NSMutableArray *enabledIdentifiers;
    NSMutableArray *disabledIdentifiers;
    NSString *_notificationName;
    NSString *_settingsFile;
    NSString *enabledKey;
    NSString *disabledKey;
    
}
@property(strong, nonatomic) NSMutableArray *reminders;
@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *completed;
@property (strong, nonatomic) NSMutableArray *arrayTag;

@end

@implementation PreferencesListController

@synthesize arrayTag;
-(void)viewDidLoad{
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.view = tableView;
    [self refreshData];
    [self.navigationItem setTitle: @"Made with Bananas"];
    NSLog(@"potato windows");
    arrayTag = [NSMutableArray array];
    
    [(UITableView *)self.view reloadData];
    
}
-(void)viewDidAppear: (BOOL) animated{
    [super viewDidAppear: true];
    [self refreshData];
    [(UITableView *)self.view reloadData];
}
-(void)refreshData{

    EKEventStore * eventStore = [[EKEventStore alloc] init];
    EKEntityType type = EKEntityTypeReminder;
    self.reminders = [[eventStore calendarsForEntityType:type] mutableCopy];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return self.reminders.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"] ?: [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];

    EKCalendar *cal = self.reminders[indexPath.row];
    
    cell.textLabel.text = cal.title;
    
    cell.tag = indexPath.row;
    NSString *strCellTag = [NSString stringWithFormat:@"%ld", (long)cell.tag];
    if(![arrayTag containsObject:strCellTag])
    {
        [arrayTag addObject:strCellTag];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *stringToMove = [arrayTag objectAtIndex:sourceIndexPath.row];
    [arrayTag removeObjectAtIndex:sourceIndexPath.row];
    [arrayTag insertObject:stringToMove atIndex:destinationIndexPath.row];
}

@end


