#import "Three20/TTLinkView.h"

@class TTImageView;
@class TTStyledView;

@interface TTThumbView : TTLinkView {
  TTImageView* imageView;
  TTStyledView* borderView;
}

@property(nonatomic,copy) NSString* thumbURL;

- (void)suspendLoading:(BOOL)suspended;

@end
