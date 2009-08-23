#import "Three20/TTGlobal.h"

@class TTLauncherView;

@interface TTLauncherItem : NSObject <NSCoding> {
  TTLauncherView* _launcher;
  NSString* _title;
  NSString* _image;
  NSString* _URL;
  NSInteger _badgeNumber;
}

@property(nonatomic,assign) TTLauncherView* launcher;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* image;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic) NSInteger badgeNumber;

- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL;

@end