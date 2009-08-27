#import "Three20/TTTableViewCell.h"

@protocol TTPhoto, TTThumbsTableViewCellDelegate;
@class TTThumbView;

@interface TTThumbsTableViewCell : TTTableViewCell {
  id<TTThumbsTableViewCellDelegate> _delegate;
  id<TTPhoto> _photo;
  NSMutableArray* _thumbViews;
  CGFloat _thumbSize;
  CGPoint _thumbOrigin;
  NSInteger _columnCount;
}

@property(nonatomic,retain) id<TTPhoto> photo;
@property(nonatomic,assign) id<TTThumbsTableViewCellDelegate> delegate;
@property(nonatomic) CGFloat thumbSize;
@property(nonatomic) CGPoint thumbOrigin;
@property(nonatomic) NSInteger columnCount;

- (void)suspendLoading:(BOOL)suspended;

@end

@protocol TTThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo;

@end
