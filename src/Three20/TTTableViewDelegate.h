#import "Three20/TTGlobal.h"

@class TTTableViewController;

/**
 * A default table view delegate implementation.
 *
 * This implementation takes care of measuring rows for you, opening URLs when the user
 * selects a cell, and suspending image loading to increase performance while the user is
 * scrolling the table.  TTTableViewController automatically assigns an instance of this
 * delegate class to your table, but you can override the createDelegate method there to provide
 * a delegate implementation of your own.
 */
@interface TTTableViewDelegate : NSObject <UITableViewDelegate> {
  TTTableViewController* _controller;
  NSMutableDictionary* _headers;
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
