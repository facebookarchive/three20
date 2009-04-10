#import "Three20/TTBadgeView.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTBadgeView

@synthesize message = _message;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithMessage:(NSString*)message {
  if (self = [self initWithFrame:CGRectZero]) {
    self.message = message;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _message = nil;

    self.style = TTSTYLE(badge);
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)dealloc {
  [_message release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (NSString*)textForLayerWithStyle:(TTStyle*)style {
  return _message;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setMessage:(NSString*)message {
  if (message != _message) {
    [_message release];
    _message = [message copy];
    [self setNeedsDisplay];
  }
}

@end
