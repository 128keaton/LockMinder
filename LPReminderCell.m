#import "LPReminderCell.h"
@implementation LPReminderCell

- (id)init {
    self = [super init];
    if (self) {
        self.dateLabel = [self.contentView viewWithTag: 1];
        self.titleLabel = [self.contentView viewWithTag: 2];
        self.urgencyLabel = [self.contentView viewWithTag: 3];
    }
    return self;
}
@end