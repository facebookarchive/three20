#import "Three20/TTGlobal.h"

@interface TTTableViewCell : UITableViewCell {
}

@property(nonatomic,retain) id object;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item;

@end
