#import "Three20/T3ImageView.h"
#import "Three20/T3PhotoSource.h"

@protocol T3Photo;
@class T3ActivityLabel;

@interface T3PhotoView : T3ImageView <T3ImageViewDelegate> {
  id <T3Photo> _photo;
  UIActivityIndicatorView* _statusSpinner;
  UILabel* _statusLabel;
  T3PhotoVersion _photoVersion;
  BOOL _extrasHidden;
}

@property(nonatomic,retain) id<T3Photo> photo;
@property(nonatomic) BOOL extrasHidden;

- (BOOL)loadPreview:(BOOL)fromNetwork;
- (void)loadImage;

- (void)showProgress:(CGFloat)progress;
- (void)showStatus:(NSString*)text;

@end
