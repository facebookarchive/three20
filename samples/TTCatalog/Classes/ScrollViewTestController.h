#import <Three20/Three20.h>

@interface ScrollViewTestController : TTViewController <TTScrollViewDataSource, TTScrollViewDelegate> {
  TTScrollView* _scrollView;
  TTPageControl* _pageControl;
  NSArray* _colors;
}

@end
