/**
 *
 *
 */
#import <UIKit/UIKit.h>

@interface TTGridViewColumn : NSObject {
    UIView* _content;
    BOOL    _visible;
}

@property (retain) UIView *content;
@property (assign,getter=isVisible) BOOL visible;

+(id)initWithContent:(UIView*)theContent;

@end
