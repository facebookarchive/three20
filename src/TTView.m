#import "Three20/TTView.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTView

@synthesize style = _style;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _style = nil;
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  [_style release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.frame = rect;
  context.contentFrame = rect;

  if (![self.style draw:context]) {
    [self drawContent:rect];
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.font = nil;
  return [_style addToSize:CGSizeZero context:context];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (void)drawLayer:(TTStyleContext*)context withStyle:(TTStyle*)style {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)drawContent:(CGRect)rect {
}

@end
