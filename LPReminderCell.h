#import <UIKit/UIKit.h>
@interface LPReminderCell : UITableViewCell
@property(strong, nonatomic) IBOutlet UILabel *dateLabel;
@property(strong, nonatomic) IBOutlet UILabel *titleLabel;
@property(strong, nonatomic) IBOutlet UILabel *urgencyLabel;
@end