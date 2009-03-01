#import "Three20/TTLinkView.h"

@class TTImageView;
@class TTBackgroundView;

@interface TTThumbView : TTLinkView {
  TTImageView* imageView;
  TTBackgroundView* borderView;
}

@property(nonatomic,copy) NSString* url;

- (void)suspendLoading:(BOOL)suspended;

@end
