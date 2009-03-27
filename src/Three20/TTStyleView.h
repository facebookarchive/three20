#import "Three20/TTAppearance.h"
#import "Three20/TTURLRequest.h"

@protocol TTStyleViewDelegate;
@class TTURLRequest;

/**
 * A decorational view that can styled using a variety of visual properties.
 */
@interface TTStyleView : UIView <TTURLRequestDelegate> {
  id<TTStyleViewDelegate> _delegate;
  TTURLRequest* _request;
  TTDrawStyle _style;
  UIColor* _fillColor;
  UIColor* _fillColor2;
  UIColor* _borderColor;
  CGFloat _borderWidth;
  CGFloat _borderRadius;
  UIEdgeInsets _backgroundInset;
  NSString* _backgroundImageURL;
  UIImage* _backgroundImage;
  UIImage* _backgroundImageDefault;
}

@property(nonatomic,assign) id<TTStyleViewDelegate> delegate;
@property(nonatomic) TTDrawStyle style;
@property(nonatomic,retain) UIColor* fillColor;
@property(nonatomic,retain) UIColor* fillColor2;
@property(nonatomic,retain) UIColor* borderColor;
@property(nonatomic) CGFloat borderWidth;
@property(nonatomic) CGFloat borderRadius;
@property(nonatomic) UIEdgeInsets backgroundInset;
@property(nonatomic,copy) NSString* backgroundImageURL;
@property(nonatomic,retain) UIImage* backgroundImage;
@property(nonatomic,retain) UIImage* backgroundImageDefault;

- (void)reload;
- (void)stopLoading;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTStyleViewDelegate <NSObject>

@optional

- (void)styleView:(TTStyleView*)imageView didLoadImage:(UIImage*)image;
- (void)styleViewDidStartLoad:(TTStyleView*)styleView;
- (void)styleView:(TTStyleView*)styleView didFailLoadWithError:(NSError*)error;

@end
