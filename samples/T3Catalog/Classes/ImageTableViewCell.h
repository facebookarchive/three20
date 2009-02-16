#import <Three20/Three20.h>

@class TTImageView;

@interface ImageTableViewCell : UITableViewCell {
  TTImageView* imageView;
}

@property(nonatomic,copy) NSString* imageURL;

@end
