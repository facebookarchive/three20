#import "Three20/TTGlobal.h"

@interface TTErrorView : UIView {
  UIImageView* _imageView;
  UILabel* _titleView;
  UILabel* _subtitleView;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image;

@end
