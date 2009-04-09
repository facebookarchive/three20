#import "Three20/TTGlobal.h"

@class TTTableViewController;

@interface TTTableViewDelegate : NSObject <UITableViewDelegate> {
  TTTableViewController* _controller;
}

- (id)initWithController:(TTTableViewController*)controller;

@property(nonatomic,readonly) TTTableViewController* controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewVarHeightDelegate : TTTableViewDelegate
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewPlainDelegate : TTTableViewDelegate
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTableViewPlainVarHeightDelegate : TTTableViewVarHeightDelegate
@end
