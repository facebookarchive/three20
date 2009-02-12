#import "Three20/T3Global.h"

@protocol T3Photo, T3ThumbsTableViewCellDelegate;
@class T3ThumbView;

@interface T3ThumbsTableViewCell : UITableViewCell {
  id<T3ThumbsTableViewCellDelegate> _delegate;
  id<T3Photo> _photo;
  T3ThumbView* _thumbView1;
  T3ThumbView* _thumbView2;
  T3ThumbView* _thumbView3;
  T3ThumbView* _thumbView4;
}

@property(nonatomic,retain) id<T3Photo> photo;
@property(nonatomic,assign) id<T3ThumbsTableViewCellDelegate> delegate;

- (void)suspendLoading:(BOOL)suspended;

@end

@protocol T3ThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(T3ThumbsTableViewCell*)cell didSelectPhoto:(id<T3Photo>)photo;

@end
