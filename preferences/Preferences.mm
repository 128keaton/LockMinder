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
    int selectedIndex;

    
}
@property(strong, nonatomic) NSMutableArray *reminders;
@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *completed;

@end

@implementation PreferencesListController

-(void)viewDidLoad{
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.view = tableView;
    [self refreshData];
    [self.navigationItem setTitle: @"LockMinder"];
    NSLog(@"potato windows");
    
    selectedIndex = -1;

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else{
        return self.reminders.count;
    }
  
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{   if(indexPath.section == 1){
        EKCalendar *cal = self.reminders[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject: cal.title forKey: @"thisIsANiceHotel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView deselectRowAtIndexPath: indexPath animated: true];
    selectedIndex = indexPath.row;
    [tableView reloadData];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 100;
    }else{
        return 44;
    }
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    [[NSUserDefaults standardUserDefaults] setBool: switchControl.on forKey: @"shouldUseRemindersAll"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"] ?: [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
         UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/Application Support/LockMinder"] pathForResource:@"background" ofType:@"png"]];
        switch (indexPath.row) {
            case 0:
           
                cell.backgroundView = [[UIImageView alloc]init];
     
                [(UIImageView *)cell.backgroundView setImage: image];
                cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
                cell.backgroundView.clipsToBounds = true;
                cell.backgroundView.backgroundColor = [UIColor redColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
            case 1:

                cell.textLabel.text = @"Use all reminder lists?";
               
                cell.accessoryView = switchView;
                [switchView setOn:[[NSUserDefaults standardUserDefaults]boolForKey:@"shouldUseRemindersAll" ] animated:NO];
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
                
            default:
                
                return cell;
                break;
        }
        
    }else{
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"] ?: [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
        if(indexPath.row == selectedIndex && selectedIndex != -1)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
   

        EKCalendar *cal = self.reminders[indexPath.row];
    
        cell.textLabel.text = cal.title;
    
    
        return cell;
    }
}



@end


