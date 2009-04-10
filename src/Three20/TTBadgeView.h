#import "Three20/TTStyledView.h"

@interface TTBadgeView : TTStyledView {
  NSString* _message;
}

@property(nonatomic,copy) NSString* message;

- (id)initWithMessage:(NSString*)message;

@end
