#import "Three20/T3Global.h"

@interface T3TableViewCell : UITableViewCell {
  id object;
}

@property(nonatomic,retain) id object;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView;

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier;

@end
