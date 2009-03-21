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
@property(nonatomic,readonly) BOOL isLoaded;

- (void)reload;
- (void)stopLoading;

- (void)imageViewDidStartLoad;
- (void)imageViewDidLoadImage:(UIImage*)image;
- (void)imageViewDidFailLoadWithError:(NSError*)error;

@end

@protocol TTImageViewDelegate <NSObject>

@optional

- (void)imageView:(TTImageView*)imageView didLoadImage:(UIImage*)image;
- (void)imageViewDidStartLoad:(TTImageView*)imageView;
- (void)imageView:(TTImageView*)imageView didFailLoadWithError:(NSError*)error;

@end
