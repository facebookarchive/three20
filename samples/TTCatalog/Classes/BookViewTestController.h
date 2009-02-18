#import <Three20/Three20.h>

@interface BookViewTestController : TTViewController <TTBookViewDelegate, TTBookViewDataSource> {
  TTBookView* _bookView;
  NSArray* _colors;
}

@end
