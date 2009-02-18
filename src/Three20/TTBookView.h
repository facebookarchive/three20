#import "Three20/TTGlobal.h"

@protocol TTBookViewDelegate;
@protocol TTBookViewDataSource;

@interface TTBookView : UIView {
  id<TTBookViewDelegate> _delegate;
  id<TTBookViewDataSource> _dataSource;
  NSInteger _centerPageIndex;
  NSInteger _visiblePageIndex;
  BOOL _scrollEnabled;
  BOOL _zoomEnabled;
  BOOL _rotateEnabled;
  CGFloat _pageSpacing;
  UIInterfaceOrientation _orientation;

  NSMutableArray* _pages;
  NSMutableArray* _pageQueue;
  NSInteger _maxPages;
  NSInteger _pageArrayIndex;
  NSTimer* _tapTimer;
  NSTimer* _animationTimer;
  NSDate* _animationStartTime;
  NSTimeInterval _animationDuration;
  UIEdgeInsets _animateEdges;
  UIEdgeInsets _pageEdges;
  UIEdgeInsets _pageStartEdges;
  UIEdgeInsets _touchEdges;
  UIEdgeInsets _touchStartEdges;
  NSUInteger _touchCount;
  CGFloat _overshoot;
  UITouch* _touch1;
  UITouch* _touch2;
  BOOL _dragging;
  BOOL _zooming;
}

/**
 *
 */
@property(nonatomic,assign) id<TTBookViewDelegate> delegate;

/**
 *
 */
@property(nonatomic,assign) id<TTBookViewDataSource> dataSource;

/**
 *
 */
@property(nonatomic) NSInteger centerPageIndex;

/**
 *
 */
@property(nonatomic) BOOL scrollEnabled;

/**
 *
 */
@property(nonatomic) BOOL zoomEnabled;

/**
 *
 */
@property(nonatomic) BOOL rotateEnabled;

/**
 *
 */
@property(nonatomic) CGFloat pageSpacing;

/**
 *
 */
@property(nonatomic) UIInterfaceOrientation orientation;

/**
 *
 */
@property(nonatomic,readonly) NSInteger numberOfPages;

/**
 *
 */
@property(nonatomic,readonly) UIView* centerPage;

/**
 * A dictionary of visible pages keyed by the index of the page.
 */
@property(nonatomic,readonly) NSDictionary* visiblePages;

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 * Gets a previously created page view that has been moved off screen and recycled.
 */
- (UIView*)dequeueReusablePage;

/**
 *
 */
- (void)reloadData;

/**
 *
 */
- (UIView*)pageAtIndex:(NSInteger)pageIndex;

@end

@protocol TTBookViewDelegate <NSObject>

/**
 *
 */
- (void)bookView:(TTBookView*)bookView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

/**
 *
 */
- (void)bookViewWillRotate:(TTBookView*)bookView toOrientation:(UIInterfaceOrientation)orientation;

/**
 *
 */
- (void)bookViewDidRotate:(TTBookView*)bookView;

/**
 *
 */
- (void)bookViewWillBeginDragging:(TTBookView*)bookView;

/**
 *
 */
- (void)bookViewDidEndDragging:(TTBookView*)bookView willDecelerate:(BOOL)willDecelerate;

/**
 *
 */
- (void)bookViewDidEndDecelerating:(TTBookView*)bookView;

/**
 *
 */
- (BOOL)bookViewShouldZoom:(TTBookView*)bookView;

/**
 *
 */
- (void)bookViewDidBeginZooming:(TTBookView*)bookView;

/**
 *
 */
- (void)bookViewDidEndZooming:(TTBookView*)bookView;

/**
 *
 */
- (void)bookViewTapped:(TTBookView*)bookView;

@optional

- (BOOL)bookView:(TTBookView*)bookView 
  shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@protocol TTBookViewDataSource <NSObject>

/**
 *
 */
- (NSInteger)numberOfPagesInBookView:(TTBookView*)bookView;

/**
 * Gets a view to display for the page at the given index.
 *
 * You do not need to position or size the view as that is done for you later.  You should
 * call dequeueReusablePage first, and only create a new view if it returns nil.
 */
- (UIView*)bookView:(TTBookView*)bookView pageAtIndex:(NSInteger)pageIndex;

/**
 * Gets the natural size of the page. 
 *
 * The actual width and height are not as important as the ratio between width and height.
 * This is used to determine how to 
 */
- (CGSize)bookView:(TTBookView*)bookView sizeOfPageAtIndex:(NSInteger)pageIndex;

@end
