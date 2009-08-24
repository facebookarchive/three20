#import "Three20/TTGlobal.h"

@class TTLauncherView;

@interface TTLauncherItem : NSObject <NSCoding> {
  TTLauncherView* _launcher;
  NSString* _title;
  NSString* _image;
  NSString* _URL;
  NSString* _style;
  NSInteger _badgeNumber;
  BOOL _canDelete;
}

@property(nonatomic,assign) TTLauncherView* launcher;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* image;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSString* style;
@property(nonatomic) NSInteger badgeNumber;
@property(nonatomic) BOOL canDelete;

- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL;
- (id)initWithTitle:(NSString*)title image:(NSString*)image URL:(NSString*)URL
      canDelete:(BOOL)canDelete;

@end