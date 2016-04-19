#import <EventKit/EventKit.h>
#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
@interface PreferencesListController
    : PSViewController <UITableViewDataSource, UITableViewDelegate> {

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
        NSString *filePath;
       
}
@property(strong, nonatomic) NSMutableArray *reminders;
@property(strong, nonatomic) EKEventStore *store;
@property(strong, nonatomic) NSMutableArray *events;
@property(strong, nonatomic) NSMutableArray *completed;
@property(strong, nonatomic)  UISwitch *switchBig;
@end

@implementation PreferencesListController

@synthesize switchBig;
- (void)viewDidLoad {
  [super viewDidLoad];
  UITableView *tableView =
      [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)
                                   style:UITableViewStyleGrouped];
  tableView.dataSource = self;
  tableView.delegate = self;
  self.view = tableView;
  [self refreshData];
  [self.navigationItem setTitle:@"LockMinder"];
  NSLog(@"potato windows");
    
  selectedIndex = -1;

  [(UITableView *)self.view reloadData];
}
-(void)saveList: (NSString *)list{
    if (filePath == nil) {
        filePath = @"/Library/Application Support/LockMinder/settings.plist";
    }
    BOOL exists;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    exists = [fileManager fileExistsAtPath:filePath];
    if (exists == false) {
        NSMutableDictionary *plistdict = [[NSMutableDictionary alloc]init];
        [plistdict setObject: list forKey: @"list"];
        [plistdict writeToFile:filePath atomically:YES];
    }else{
        NSMutableDictionary *plistdict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        [plistdict setObject: list forKey: @"list"];
        [plistdict writeToFile:filePath atomically:YES];
    }

    
}
-(void)saveListOption: (BOOL) option{
    if (filePath == nil) {
        filePath = @"/Library/Application Support/LockMinder/settings.plist";
    }
    BOOL exists;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    exists = [fileManager fileExistsAtPath:filePath];
    if (exists == false) {
        NSMutableDictionary *plistdict = [[NSMutableDictionary alloc]init];
        [plistdict setObject: @(option) forKey: @"useLists"];
        [plistdict writeToFile:filePath atomically:YES];
    }else{
        NSMutableDictionary *plistdict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        [plistdict setObject: @(option) forKey: @"useLists"];
        [plistdict writeToFile:filePath atomically:YES];
    }

}
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:true];
  [self refreshData];
  [(UITableView *)self.view reloadData];
}
- (void)refreshData {

  EKEventStore *eventStore = [[EKEventStore alloc] init];
  EKEntityType type = EKEntityTypeReminder;
  self.reminders = [[eventStore calendarsForEntityType:type] mutableCopy];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
  return 3;
}

- (NSInteger)tableView:(UITableView *)table
 numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 2;
  } else if (section == 1) {
    return self.reminders.count;
  } else {
    return 2;
  }
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    EKCalendar *cal = self.reminders[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:cal.title
                                              forKey:@"thisIsANiceHotel"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"shouldUseRemindersAll"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
      [self saveList: cal.title];
      [self saveListOption: false];


      for (UIView *view in self.view.subviews) {
          if (view.tag == 1773) {
              [(UISwitch *)view setOn: NO animated: YES];
          }
      }
      
      [switchBig setOn: NO animated: YES];
    selectedIndex = indexPath.row;
    [tableView reloadData];
  } else if (indexPath.section == 2){
    if (indexPath.row == 0) {
      [[UIApplication sharedApplication]
          openURL:[NSURL URLWithString:@"http://128keaton.com/donate"]];
    } else {
      [[UIApplication sharedApplication]
          openURL:[NSURL URLWithString:@"https://twitter.com/128keaton"]];
    }
  }
}
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 0) {
    return 100;
  } else {
    return 44;
  }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
  
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);

    label.text = @"Copyright 2016 Keaton Burleson";
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
    }else{
        return nil;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);

    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = @"LISTS - TAP TO CHOOSE ONE";
       
        
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
    }else{
        return nil;
    }
}


- (void)switchChanged:(id)sender {
  UISwitch *switchControl = sender;
  NSLog(@"The switch is %@", switchControl.on ? @"ON" : @"OFF");
  [[NSUserDefaults standardUserDefaults] setBool:switchControl.on
                                          forKey:@"shouldUseRemindersAll"];
  [[NSUserDefaults standardUserDefaults] synchronize];
[self saveListOption: switchControl.on];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"cell"]
            ?: [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                   reuseIdentifier:@"cell"] autorelease];
    switchBig = [[UISwitch alloc] initWithFrame:CGRectZero];
      switchBig.tag = 1337;
    UIImage *image = [UIImage
        imageWithContentsOfFile:
            [[NSBundle
                bundleWithPath:@"/Library/Application Support/LockMinder"]
                pathForResource:@"background"
                         ofType:@"png"]];
    if (indexPath.row == 0 && indexPath.section == 0) {

      cell.backgroundView = [[UIImageView alloc] init];

      [(UIImageView *)cell.backgroundView setImage:image];
      cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
      cell.backgroundView.clipsToBounds = true;
      cell.backgroundView.backgroundColor = [UIColor redColor];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      return cell;
    } else if (indexPath.row == 1 && indexPath.section == 0) {

      cell.textLabel.text = @"Use all reminder lists?";

      cell.accessoryView = switchBig;
      [switchBig setOn:[[NSUserDefaults standardUserDefaults]
                            boolForKey:@"shouldUseRemindersAll"]
               animated:true];
      [switchBig addTarget:self
                     action:@selector(switchChanged:)
           forControlEvents:UIControlEventValueChanged];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      return cell;
    }

  } else if (indexPath.section == 1) {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"cell2"]
            ?: [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                   reuseIdentifier:@"cell2"] autorelease];
    if (indexPath.row == selectedIndex && selectedIndex != -1) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }

    EKCalendar *cal = self.reminders[indexPath.row];

    cell.textLabel.text = cal.title;

    return cell;
  } else if (indexPath.section == 2) {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"cell3"]
            ?: [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle
                   reuseIdentifier:@"cell3"] autorelease];
    if (indexPath.row == 0 && indexPath.section == 2) {
      cell.textLabel.text = @"Donate to the developer";
    } else if (indexPath.row == 1 && indexPath.section == 2) {
      cell.textLabel.text = @"Follow the developer on Twitter!";
    }
    cell.textLabel.textColor = self.view.tintColor;
    return cell;
  }
  return [[UITableViewCell alloc] init];
}

@end
