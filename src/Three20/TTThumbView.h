#import "Three20/TTGlobal.h"

@class TTImageView;
@class TTBackgroundView;

@interface TTThumbView : UIControl {
  TTImageView* imageView;
  TTBackgroundView* borderView;
}

@property(nonatomic,copy) NSString* url;

- (void)suspendLoading:(BOOL)suspended;

@end
