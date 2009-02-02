#import <Three20/Three20.h>

@class T3ImageView;

@interface ImageTableViewCell : UITableViewCell {
  T3ImageView* imageView;
}

@property(nonatomic,copy) NSString* imageURL;

@end
