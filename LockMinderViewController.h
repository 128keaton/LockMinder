
#import "lockpages/LPPage-Protocol.h"
#import "MBProgressHUD.h"
@interface LockMinderViewController : UITableViewController <LPPage, UITextFieldDelegate>
@property (nonatomic, retain) UIView *ibView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableArray *completed;

@end

