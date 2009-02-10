#import "Three20/T3Global.h"

@class T3ThumbView;
@protocol T3Photo;

@interface T3ThumbsTableViewCell : UITableViewCell {
  id<T3Photo> _photo;
  T3ThumbView* _thumbView1;
  T3ThumbView* _thumbView2;
  T3ThumbView* _thumbView3;
  T3ThumbView* _thumbView4;
}

@property(nonatomic,retain) id<T3Photo> photo;

- (void)pauseLoading:(BOOL)paused;

@end