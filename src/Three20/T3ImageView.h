#import "Three20/T3URLRequest.h"

@protocol T3ImageViewDelegate;

@interface T3ImageView : UIImageView<T3URLRequestDelegate> {
  id<T3ImageViewDelegate> _delegate;
  T3URLRequest* _request;
  NSString* _url;
  UIImage* _defaultImage;
  BOOL _autoresizesToImage;
}

@property(nonatomic,assign) id<T3ImageViewDelegate> delegate;
@property(nonatomic,copy) NSString* url;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic) BOOL autoresizesToImage;
@property(nonatomic,readonly) BOOL loading;

- (void)reload;
- (void)stopLoading;

@end

@protocol T3ImageViewDelegate <NSObject>

- (void)imageView:(T3ImageView*)imageView loaded:(UIImage*)image;

@optional
- (void)imageViewPosted:(T3ImageView*)imageView;
- (void)imageViewLoading:(T3ImageView*)imageView;
- (void)imageViewLoaded:(T3ImageView*)imageView;
- (void)imageView:(T3ImageView*)imageView loadDidFailWithError:(NSError*)error;

@end
