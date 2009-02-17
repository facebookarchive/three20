#import "Three20/TTGlobal.h"

@interface TTTableViewCell : UITableViewCell {
  id object;
}

@property(nonatomic,retain) id object;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForItem:(id)item;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier;

@end
