#import "Three20/T3Global.h"

@class T3ThumbView;
@protocol T3Photo;

@interface T3ThumbsTableViewCell : UITableViewCell {
  id<T3Photo> photo;
  T3ThumbView* thumbView1;
  T3ThumbView* thumbView2;
  T3ThumbView* thumbView3;
  T3ThumbView* thumbView4;
}

@property(nonatomic,retain) id<T3Photo> photo;

- (void)pauseLoading:(BOOL)paused;

@end