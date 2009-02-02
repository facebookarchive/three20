#import "Three20/T3Global.h"

@class T3ImageView;
@class T3BackgroundView;

@interface T3ThumbView : UIControl {
  T3ImageView* imageView;
  T3BackgroundView* borderView;
}

@property(nonatomic,copy) NSString* url;

- (void)pauseLoading:(BOOL)paused;

@end
