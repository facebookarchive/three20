#import "Three20/T3Global.h"

@protocol T3ScrollViewDelegate;
@protocol T3ScrollViewDataSource;

@interface T3ScrollView : UIView {
  id<T3ScrollViewDelegate> _delegate;
  id<T3ScrollViewDataSource> _dataSource;
  NSInteger _centerPageIndex;
  NSInteger _visiblePageIndex;
  BOOL _scrollEnabled;
  BOOL _zoomEnabled;
  BOOL _rotateEnabled;
  CGFloat _pageSpacing;
  UIInterfaceOrientation _orientation;

  NSMutableArray* _pages;
  NSMutableArray* _pageQueue;
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
@property(nonatomic,assign) id<T3ScrollViewDelegate> delegate;

/**
 *
 */
@property(nonatomic,assign) id<T3ScrollViewDataSource> dataSource;

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

@protocol T3ScrollViewDelegate <NSObject>

/**
 *
 */
- (void)scrollView:(T3ScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

/**
 *
 */
- (void)scrollViewWillRotate:(T3ScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidRotate:(T3ScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewWillBeginDragging:(T3ScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndDragging:(T3ScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

/**
 *
 */
- (void)scrollViewDidEndDecelerating:(T3ScrollView*)scrollView;

/**
 *
 */
- (BOOL)scrollViewShouldZoom:(T3ScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidBeginZooming:(T3ScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndZooming:(T3ScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewTapped:(T3ScrollView*)scrollView;

@optional

- (BOOL)scrollView:(T3ScrollView*)scrollView 
  shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@protocol T3ScrollViewDataSource <NSObject>

/**
 *
 */
- (NSInteger)numberOfPagesInScrollView:(T3ScrollView*)scrollView;

/**
 * Gets a view to display for the page at the given index.
 *
 * You do not need to position or size the view as that is done for you later.  You should
 * call dequeueReusablePage first, and only create a new view if it returns nil.
 */
- (UIView*)scrollView:(T3ScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex;

/**
 * Gets the natural size of the page. 
 *
 * The actual width and height are not as important as the ratio between width and height.
 * This is used to determine how to 
 */
- (CGSize)scrollView:(T3ScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex;

@end
