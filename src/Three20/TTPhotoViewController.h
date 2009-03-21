#import "Three20/TTViewController.h"
#import "Three20/TTPhotoSource.h"
#import "Three20/TTScrollView.h"
#import "Three20/TTThumbsViewController.h"

@class TTScrollView, TTPhotoView;

@interface TTPhotoViewController : TTViewController
    <TTScrollViewDelegate, TTScrollViewDataSource, TTPhotoSourceDelegate,
      TTThumbsViewControllerDelegate> {
  id<TTPhotoSource> _photoSource;
  id<TTPhoto> _centerPhoto;
  NSUInteger _centerPhotoIndex;
  UIView* _innerView;
  TTScrollView* _scrollView;
  TTPhotoView* _photoStatusView;
  UIToolbar* _toolbar;
  UIBarButtonItem* _nextButton;
  UIBarButtonItem* _previousButton;
  UIImage* _defaultImage;
  NSString* _statusText;
  TTThumbsViewController* _thumbsController;
  NSTimer* _slideshowTimer;
  NSTimer* _loadTimer;
  BOOL _delayLoad;
}

/**
 * The source of a sequential photo collection that will be displayed.
 */
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

/**
 * The photo that is currently visible and centered.
 *
 * You can assign this directly to change the photoSource to the one that contains the photo.
 */
@property(nonatomic,assign) id<TTPhoto> centerPhoto;

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

- (TTPhotoView*)createPhotoView;

- (TTThumbsViewController*)createThumbsViewController;

@end
