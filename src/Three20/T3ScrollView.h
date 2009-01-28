#import "Three20/T3Global.h"

@protocol T3ScrollViewDelegate;
@protocol T3ScrollViewDataSource;

@interface T3ScrollView : UIView {
  id<T3ScrollViewDelegate> _delegate;
  id<T3ScrollViewDataSource> _dataSource;
  NSInteger _currentPageIndex;
  BOOL _scrollEnabled;
  BOOL _zoomEnabled;
  BOOL _rotateEnabled;
  CGFloat _pageSpacing;
  UIInterfaceOrientation _orientation;

  NSMutableArray* _pageViews;
  NSMutableArray* _pageViewQueue;
  NSInteger _pageArrayIndex;
  NSTimer* _animationTimer;
  NSDate* _animationStartTime;
  NSTimeInterval _animationDuration;
  UIEdgeInsets _animateEdges;
  UIEdgeInsets _pageEdges;
  UIEdgeInsets _pageStartEdges;
  UIEdgeInsets _touchEdges;
  UIEdgeInsets _touchStartEdges;
  NSUInteger _touchCount;
  UITouch* _touch1;
  UITouch* _touch2;
}

/**
 *
 */
@property (nonatomic, assign) id<T3ScrollViewDelegate> delegate;

/**
 *
 */
@property (nonatomic, assign) id<T3ScrollViewDataSource> dataSource;

/**
 *
 */
@property (nonatomic) NSInteger currentPageIndex;

/**
 *
 */
@property (nonatomic) BOOL scrollEnabled;

/**
 *
 */
@property (nonatomic) BOOL zoomEnabled;

/**
 *
 */
@property (nonatomic) BOOL rotateEnabled;

/**
 *
 */
@property (nonatomic) CGFloat pageSpacing;

/**
 *
 */
@property (nonatomic) UIInterfaceOrientation orientation;

/**
 *
 */
@property (nonatomic, readonly) UIView* currentPageView;

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 *
 */
- (UIView*)dequeueReusablePage;

/**
 *
 */
- (void)rebuild;

@end

@protocol T3ScrollViewDelegate <NSObject>

@optional
- (BOOL)scrollView:(T3ScrollView*)scrollView 
  shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@protocol T3ScrollViewDataSource <NSObject>

/**
 *
 */
- (NSInteger)numberOfItemsInScrollView:(T3ScrollView*)scrollView;

/**
 *
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
