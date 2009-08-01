#import "Three20/TTModelViewController.h"
#import "Three20/TTPhotoSource.h"
#import "Three20/TTScrollView.h"
#import "Three20/TTThumbsViewController.h"

@class TTScrollView, TTPhotoView, TTStyle;

@interface TTPhotoViewController : TTModelViewController
          <TTScrollViewDelegate, TTScrollViewDataSource, TTThumbsViewControllerDelegate> {
  id<TTPhotoSource> _photoSource;
  id<TTPhoto> _centerPhoto;
  NSInteger _centerPhotoIndex;
  UIView* _innerView;
  TTScrollView* _scrollView;
  TTPhotoView* _photoStatusView;
  UIToolbar* _toolbar;
  UIBarButtonItem* _nextButton;
  UIBarButtonItem* _previousButton;
  TTStyle* _captionStyle;
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
@property(nonatomic,retain) id<TTPhoto> centerPhoto;

/**
 * The index of the currently visible photo.
 *
 * Because centerPhoto can be nil while waiting for the source to load the photo, this property
 * must be maintained even though centerPhoto has its own index property.
 */
@property(nonatomic,readonly) NSInteger centerPhotoIndex;

/**
 * The default image to show before a photo has been loaded.
 */
@property(nonatomic,retain) UIImage* defaultImage;

/**
 * The style to use for the caption label.
 */
@property(nonatomic,retain) TTStyle* captionStyle;

- (id)initWithPhoto:(id<TTPhoto>)photo;
- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource;

/**
 * Creates a photo view for a new page.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (TTPhotoView*)createPhotoView;

/**
 * Creates the thumbnail controller used by the "See All" button.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (TTThumbsViewController*)createThumbsViewController;

/**
 * Sent to the controller after it moves from one photo to another.
 */
- (void)didMoveToPhoto:(id<TTPhoto>)photo fromPhoto:(id<TTPhoto>)fromPhoto;

@end
