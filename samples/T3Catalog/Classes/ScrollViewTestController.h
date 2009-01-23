#import "Three20/Three20.h"

@interface ScrollViewTestController : T3ViewController
    <T3ScrollViewDelegate, T3ScrollViewDataSource> {
  T3ScrollView* _scrollView;
  NSArray* colors;
}

@end
