#import "Three20/TTGlobal.h"

@class TTStyle;

/**
 * TTPageControl is a version of UIPageControl which allows you to style the dots.
 */
@interface TTPageControl : UIControl {
  NSInteger _numberOfPages;
  NSInteger _currentPage;
  NSString* _dotStyle;
  TTStyle* _normalDotStyle;
  TTStyle* _currentDotStyle;
  BOOL _hidesForSinglePage;
}

@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;
@property(nonatomic,copy) NSString* dotStyle;
@property(nonatomic) BOOL hidesForSinglePage;

@end
