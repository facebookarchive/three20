#import "Three20/T3Global.h"

@protocol T3ScrollViewDelegate;
@protocol T3ScrollViewDataSource;

@interface T3ScrollView : UIView {
  id<T3ScrollViewDelegate> _delegate;
  id<T3ScrollViewDataSource> _dataSource;
  NSMutableArray* _pageViews;
  NSMutableArray* _pageViewQueue;
  NSInteger _currentPageIndex;
  NSInteger _pageArrayIndex;
  CGFloat _pageSpacing;
  NSTimer* _glideTimer;
  NSDate* _glideStartTime;
  CGFloat _glideStartPoint;
  CGFloat _dragStartPoint;
  CGFloat _dragLastPoint;
  NSTimeInterval _dragLastMoveTime;
  BOOL _tracking;
  BOOL _dragging;
  BOOL _flicked;
  BOOL _scrollEnabled;
}

@property (nonatomic, assign) id<T3ScrollViewDelegate> delegate;
@property (nonatomic, assign) id<T3ScrollViewDataSource> dataSource;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) BOOL scrollEnabled;

- (UIView*)dequeueReusablePage;

@end

@protocol T3ScrollViewDelegate <NSObject>

@end

@protocol T3ScrollViewDataSource <NSObject>

- (NSInteger)numberOfItemsInScrollView:(T3ScrollView*)scrollView;
- (UIView*)scrollView:(T3ScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex;

@end
