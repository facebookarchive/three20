#import "Three20/T3Global.h"

@interface T3ErrorView : UIView {
  UIImageView* imageView;
  UILabel* titleView;
  UILabel* captionView;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* caption;

- (id)initWithTitle:(NSString*)title caption:(NSString*)caption image:(UIImage*)image;

@end
