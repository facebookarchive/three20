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
  CGFloat _contentOrigin;
}

@property(nonatomic,retain) TTStyledTextLabel* highlightedLabel;
@property(nonatomic) CGFloat contentOrigin;

@end

@protocol TTTableViewDelegate <UITableViewDelegate>

- (void)tableView:(UITableView*)tableView touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)tableView:(UITableView*)tableView touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

@end
