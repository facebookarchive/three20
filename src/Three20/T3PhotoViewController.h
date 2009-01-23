#import "Three20/T3ViewController.h"
#import "Three20/T3PhotoSource.h"
#import "Three20/T3PhotoView.h"

@interface T3PhotoViewController : T3ViewController
    <UIScrollViewDelegate, T3PhotoSourceDelegate, T3PhotoViewDelegate> {
  UIScrollView* scrollView;
  T3PhotoView* photoView;
  T3PhotoView* photoViewLeft;
  T3PhotoView* photoViewRight;

  id<T3PhotoSource> photoSource;
  id<T3Photo> visiblePhoto;
  NSUInteger visiblePhotoIndex;
  UIInterfaceOrientation orientation;
  UIBarStyle previousBarStyle;
}

/**
 * The source of a sequential photo collection that will be displayed.
 */
@property (nonatomic, retain) id<T3PhotoSource> photoSource;

/**
 * The photo that is currently visible and centered.
 *
 * You can assign this directly to change the photoSource to the one that contains the photo.
 */
@property (nonatomic, assign) id<T3Photo> visiblePhoto;

/**
 * The index of the currently visible photo.
 *
 * Because visiblePhoto can be nil while waiting for the source to load the photo, this property
 * must be maintained even though visiblePhoto has its own index property.
 */
@property (nonatomic, readonly) NSUInteger visiblePhotoIndex;

/**
 * Show or hide the toolbar and status bar that overlay the photo.
 */
- (void)showChrome:(BOOL)show animated:(BOOL)animated;

@end
