#import "Three20/TTStyle.h"

typedef enum {
  TTButtonTypeToolbar,
  TTButtonTypeToolbarBack,
  TTButtonTypeToolbarForward,
  TTButtonTypeEmbossed,
  TTButtonTypeToolbarRound,
} TTButtonType;

@interface TTButton : UIControl <TTStyleDelegate> {
  NSMutableDictionary* _content;
  UIFont* _font;
}

@property(nonatomic,retain) UIFont* font;

+ (TTButton*)buttonWithType:(TTButtonType)type title:(NSString*)title color:(UIColor*)color;
+ (TTButton*)buttonWithStyle:(NSString*)className title:(NSString*)title;

- (NSString*)titleForState:(UIControlState)state;
- (void)setTitle:(NSString*)title forState:(UIControlState)state;

- (NSString*)imageForState:(UIControlState)state;
- (void)setImage:(NSString*)title forState:(UIControlState)state;

- (TTStyle*)styleForState:(UIControlState)state;
- (void)setStyle:(TTStyle*)style forState:(UIControlState)state;

- (void)suspendLoadingImages:(BOOL)suspended;

@end
