#import "Three20/TTLinkView.h"

@class TTImageView;
@class TTStyleView;

@interface TTThumbView : TTLinkView {
  TTImageView* imageView;
  TTStyleView* borderView;
}

@property(nonatomic,copy) NSString* thumbURL;

- (void)suspendLoading:(BOOL)suspended;

@end
