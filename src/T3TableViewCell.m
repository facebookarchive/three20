#import "Three20/T3TableViewCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableViewCell

@synthesize object;

+ (CGFloat)rowHeightForItem:(id)item tableView:(UITableView*)tableView {
  return TOOLBAR_HEIGHT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame style:(int)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    object = nil;
  }
  return self;
}

- (void)dealloc {
  [object release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewCell

- (void)prepareForReuse {
  self.object = nil;
  [super prepareForReuse];
}

@end
