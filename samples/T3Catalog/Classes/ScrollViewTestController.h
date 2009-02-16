#import <Three20/Three20.h>

@interface ScrollViewTestController : TTViewController
    <TTScrollViewDelegate, TTScrollViewDataSource> {
  TTScrollView* _scrollView;
  NSArray* objects;
}

@end
