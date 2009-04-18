#import "Three20/TTTableViewCell.h"

@protocol TTPhoto, TTThumbsTableViewCellDelegate;
@class TTThumbView;

@interface TTThumbsTableViewCell : TTTableViewCell {
  id<TTThumbsTableViewCellDelegate> _delegate;
  id<TTPhoto> _photo;
  TTThumbView* _thumbView1;
  TTThumbView* _thumbView2;
  TTThumbView* _thumbView3;
  TTThumbView* _thumbView4;
  CGFloat _thumbSize;
  CGPoint _thumbOrigin;
}

@property(nonatomic,retain) id<TTPhoto> photo;
@property(nonatomic,assign) id<TTThumbsTableViewCellDelegate> delegate;
@property(nonatomic) CGFloat thumbSize;
@property(nonatomic) CGPoint thumbOrigin;

- (void)suspendLoading:(BOOL)suspended;

@end

@protocol TTThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo;

@end
