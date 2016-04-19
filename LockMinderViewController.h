
#import "lockpages/LPPage-Protocol.h"
#import "MBProgressHUD.h"
#import <EventKit/EventKit.h>
@interface LockMinderViewController : UITableViewController <LPPage, UITextFieldDelegate>{
    NSString *filePath;

}
@property (nonatomic, retain) UIView *ibView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *completed;
@property (strong, nonatomic) EKEventStore *store;

@end

