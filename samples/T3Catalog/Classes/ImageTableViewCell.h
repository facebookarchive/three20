#import <UIKit/UIKit.h>

@class T3ImageView;

@interface ImageTableViewCell : UITableViewCell {
  T3ImageView* imageView;
}

@property(nonatomic, copy) NSString* imageURL;

@end
