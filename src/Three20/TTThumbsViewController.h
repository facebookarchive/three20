#import "Three20/TTTableViewController.h"
#import "Three20/TTPhotoSource.h"
#import "Three20/TTThumbsTableViewCell.h"

@protocol TTThumbsViewControllerDelegate;
@class TTPhotoViewController;

@interface TTThumbsViewController : TTTableViewController
    <TTPhotoSourceDelegate, TTThumbsTableViewCellDelegate, UITableViewDataSource> {
  id<TTThumbsViewControllerDelegate> _delegate;
  id<TTPhotoSource> _photoSource;
}

@property(nonatomic,assign) id<TTThumbsViewControllerDelegate> delegate;
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

- (TTPhotoViewController*)createPhotoViewController;

@end

@protocol TTThumbsViewControllerDelegate <NSObject>

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo;

@optional
- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
  shouldNavigateToPhoto:(id<TTPhoto>)photo;

@end
