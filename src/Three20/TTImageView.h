#import "Three20/TTURLRequest.h"

@protocol TTImageViewDelegate;

@interface TTImageView : UIImageView<TTURLRequestDelegate> {
  id<TTImageViewDelegate> _delegate;
  TTURLRequest* _request;
  NSString* _url;
  UIImage* _defaultImage;
  BOOL _autoresizesToImage;
}

@property(nonatomic,assign) id<TTImageViewDelegate> delegate;
@property(nonatomic,copy) NSString* url;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic) BOOL autoresizesToImage;
@property(nonatomic,readonly) BOOL isLoading;

- (void)reload;
- (void)stopLoading;

@end

@protocol TTImageViewDelegate <NSObject>

- (void)imageView:(TTImageView*)imageView didLoadImage:(UIImage*)image;

@optional
- (void)imageViewDidStartLoad:(TTImageView*)imageView;
- (void)imageView:(TTImageView*)imageView didFailLoadWithError:(NSError*)error;

@end
