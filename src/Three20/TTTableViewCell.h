#import "Three20/TTGlobal.h"

@interface TTTableViewCell : UITableViewCell {
  id object;
}

@property(nonatomic,retain) id object;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView;

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier;

@end
