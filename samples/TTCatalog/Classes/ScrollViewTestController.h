#import <Three20/Three20.h>

@interface ScrollViewTestController : TTViewController <TTScrollViewDataSource> {
  TTScrollView* _scrollView;
  NSArray* _colors;
}

@end
