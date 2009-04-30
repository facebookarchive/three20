#import "Three20/TTGlobal.h"

@class TTStyledTextLabel;

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * TTTableView enhances UITableView to provide support for various Three20 services.
 *
 * If you are using TTStyledTextLabels in your table cells, you need to use TTTableView if
 * you want links in your labels to be touchable.
 */
@interface TTTableView : UITableView {
  TTStyledTextLabel* _highlightedLabel;
  CGPoint _highlightStartPoint;
  UIView* _menuView;
  UITableViewCell* _menuCell;
}

@property(nonatomic,retain) TTStyledTextLabel* highlightedLabel;

- (void)showMenu:(UIView*)view forCell:(UITableViewCell*)cell animated:(BOOL)animated;
- (void)hideMenu:(BOOL)animated;

@end
