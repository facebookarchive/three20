#import "Three20/T3ImageView.h"

@protocol T3Photo, T3Album, T3PhotoViewDelegate;
@class T3ActivityLabel;
@class T3ImageView;
@class T3PhotoViewController;

@interface T3PhotoView : UIView <T3ImageViewDelegate> {
  id<T3PhotoViewDelegate> delegate;
  id <T3Photo> photo;
  UIInterfaceOrientation orientation;
  T3ImageView* imageView;
  T3ActivityLabel* activityView;
  int touchCount;
  BOOL isPrimary;
}

@property(nonatomic, assign) id<T3PhotoViewDelegate> delegate;
@property(nonatomic, retain) id<T3Photo> photo;

- (void)layout:(UIInterfaceOrientation)orientation from:(UIInterfaceOrientation)fromOrientation
  stage:(int)stage;

- (BOOL)loadPreview;
- (void)loadThumbnail;
- (void)loadImage;

- (void)showActivity:(NSString*)text;

- (void)photoTouchBegan:(UITouch*)touch;
- (void)photoTouchEnded:(UITouch*)touch;

@end

@protocol T3PhotoViewDelegate <NSObject>

- (void)photoViewTapped:(T3PhotoView*)photoView;

@end