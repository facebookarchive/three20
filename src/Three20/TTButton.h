#import "Three20/TTStyle.h"

@interface TTButton : UIControl <TTStyleDelegate> {
  NSMutableDictionary* _content;
  UIFont* _font;
}

@property(nonatomic,retain) UIFont* font;

+ (TTButton*)buttonWithStyle:(NSString*)selector;
+ (TTButton*)buttonWithStyle:(NSString*)selector title:(NSString*)title;

- (NSString*)titleForState:(UIControlState)state;
- (void)setTitle:(NSString*)title forState:(UIControlState)state;

- (NSString*)imageForState:(UIControlState)state;
- (void)setImage:(NSString*)title forState:(UIControlState)state;

- (TTStyle*)styleForState:(UIControlState)state;
- (void)setStyle:(TTStyle*)style forState:(UIControlState)state;

/**
 * Sets the styles for all control states using a single style selector.
 *
 * The method for the selector must accept a single argument for the control state.  It will
 * be called to return a style for each of the different control states.
 */
- (void)setStylesWithSelector:(NSString*)selector;

- (void)suspendLoadingImages:(BOOL)suspended;

@end
