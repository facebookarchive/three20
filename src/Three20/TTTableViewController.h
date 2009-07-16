#import "Three20/TTModelViewController.h"
#import "Three20/TTTableViewDataSource.h"

@class TTActivityLabel;

@interface TTTableViewController : TTModelViewController {
  UITableView* _tableView;
  UIView* _tableBannerView;
  UIView* _tableOverlayView;
  id<TTTableViewDataSource> _dataSource;
  id<UITableViewDelegate> _tableDelegate;
  NSTimer* _bannerTimer;
  UITableViewStyle _tableViewStyle;
  BOOL _variableHeightRows;
}

@property(nonatomic,retain) UITableView* tableView;

/**
 * A view that is displayed as a banner at the bottom of the table view.
 */
@property(nonatomic,retain) UIView* tableBannerView;

/**
 * A view that is displayed over the table view.
 */
@property(nonatomic,retain) UIView* tableOverlayView;

/** 
 * The data source used to populate the table view.
 *
 * Setting dataSource has the side effect of also setting model to the value of the
 * dataSource's model property.
 */
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;

/**
 * The style of the table view.
 */
@property(nonatomic) UITableViewStyle tableViewStyle;

/** 
 * Indicates if the table should support non-fixed row heights.
 */
@property(nonatomic) BOOL variableHeightRows;

/**
 * Initializes and returns a controller having the given style.
 */
- (id)initWithStyle:(UITableViewStyle)style;

/**
 * Creates an delegate for the table view.
 *
 * Subclasses can override this to provide their own table delegate implementation.
 */
- (id<UITableViewDelegate>)createDelegate;

/**
 * Sets the view that is displayed at the bottom of the table view with an optional animation.
 */
- (void)setTableBannerView:(UIView*)tableBannerView animated:(BOOL)animated;

/**
 * Sets the view that is displayed over the table view with an optional animation.
 */
- (void)setTableOverlayView:(UIView*)tableOverlayView animated:(BOOL)animated;

/**
 * Tells the controller that the user selected an object in the table.
 */
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Asks if a URL from that user touched in the table should be opened.
 */
- (BOOL)shouldOpenURL:(NSString*)URL;

/**
 * Tells the controller that the user began dragging the table view.
 */
- (void)didBeginDragging;

/**
 * Tells the controller that the user stopped dragging the table view.
 */
- (void)didEndDragging;

@end
