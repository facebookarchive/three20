#import "Three20/T3ViewController.h"
#import "Three20/T3PhotoSource.h"
#import "Three20/T3URLRequest.h"
#import "Three20/T3ScrollView.h"

@protocol T3PhotoViewControllerDelegate;
@class T3ScrollView, T3PhotoView;

@interface T3PhotoViewController : T3ViewController
    <T3ScrollViewDelegate, T3ScrollViewDataSource, T3URLRequestDelegate> {
  id<T3PhotoViewControllerDelegate> _delegate;
  id<T3PhotoSource> _photoSource;
  id<T3Photo> _centerPhoto;
  NSUInteger _centerPhotoIndex;
  T3ScrollView* _scrollView;
  T3PhotoView* _photoStatusView;
  UIImage* _defaultImage;
  NSString* _statusText;
  UIBarStyle _previousBarStyle;
  UIColor* _previousBarTintColor;
  NSTimer* _loadTimer;
  BOOL _delayLoad;
}

@property(nonatomic,assign) id<T3PhotoViewControllerDelegate> delegate;

/**
 * The source of a sequential photo collection that will be displayed.
 */
@property(nonatomic,retain) id<T3PhotoSource> photoSource;

/**
 * The photo that is currently visible and centered.
 *
 * You can assign this directly to change the photoSource to the one that contains the photo.
 */
@property(nonatomic,assign) id<T3Photo> centerPhoto;

/**
 * The index of the currently visible photo.
 *
 * Because centerPhoto can be nil while waiting for the source to load the photo, this property
 * must be maintained even though centerPhoto has its own index property.
 */
@property(nonatomic,readonly) NSUInteger centerPhotoIndex;

/**
 * The default image to show before a photo has been loaded.
 */
@property(nonatomic,retain) UIImage* defaultImage;

@end

@protocol T3PhotoViewControllerDelegate

- (T3PhotoView*)photoViewController:(T3PhotoViewController*)controller
  viewForPhotoAtIndex:(NSInteger)photoIndex;

@end