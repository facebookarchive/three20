#import "Three20/T3TableViewController.h"
#import "Three20/T3PhotoSource.h"
#import "Three20/T3ThumbsTableViewCell.h"

@protocol T3ThumbsViewControllerDelegate;
@class T3PhotoViewController;

@interface T3ThumbsViewController : T3TableViewController
    <T3PhotoSourceDelegate, T3ThumbsTableViewCellDelegate, UITableViewDataSource> {
  id<T3ThumbsViewControllerDelegate> _delegate;
  id<T3PhotoSource> _photoSource;
}

@property(nonatomic,assign) id<T3ThumbsViewControllerDelegate> delegate;
@property(nonatomic,retain) id<T3PhotoSource> photoSource;

- (T3PhotoViewController*)createPhotoViewController;

@end

@protocol T3ThumbsViewControllerDelegate <NSObject>

- (void)thumbsViewController:(T3ThumbsViewController*)controller didSelectPhoto:(id<T3Photo>)photo;

@optional
- (BOOL)thumbsViewController:(T3ThumbsViewController*)controller
  shouldNavigateToPhoto:(id<T3Photo>)photo;

@end
