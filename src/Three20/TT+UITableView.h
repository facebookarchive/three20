#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITableView (TTCategory)

/**
 * The view that contains the "index" along the right side of the table.
 */
@property(nonatomic,readonly) UIView* indexView;

- (void)touchRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

- (void)scrollToBottom:(BOOL)animated;

@end
