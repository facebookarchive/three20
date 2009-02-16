#import "Three20/TTImageView.h"
#import "Three20/TTPhotoSource.h"

@protocol TTPhoto;
@class TTActivityLabel;

@interface TTPhotoView : TTImageView <TTImageViewDelegate> {
  id <TTPhoto> _photo;
  UIActivityIndicatorView* _statusSpinner;
  UILabel* _statusLabel;
  UILabel* _captionLabel;
  TTPhotoVersion _photoVersion;
  BOOL _extrasHidden;
  BOOL _captionHidden;
}

@property(nonatomic,retain) id<TTPhoto> photo;
@property(nonatomic) BOOL extrasHidden;
@property(nonatomic) BOOL captionHidden;

- (BOOL)loadPreview:(BOOL)fromNetwork;
- (void)loadImage;

- (void)showProgress:(CGFloat)progress;
- (void)showStatus:(NSString*)text;

@end
