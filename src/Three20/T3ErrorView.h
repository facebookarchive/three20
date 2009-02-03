#import "Three20/T3Global.h"

@interface T3ErrorView : UIView {
  UIImageView* imageView;
  UILabel* titleView;
  UILabel* subtitleView;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image;

@end
