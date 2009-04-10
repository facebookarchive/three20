#import "Three20/TTStyledView.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledView

@synthesize style = _style, backgroundInset = _backgroundInset;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGRect)backgroundBounds {
  CGRect frame = self.frame;
  return CGRectMake(_backgroundInset.left, _backgroundInset.top,
    frame.size.width - (_backgroundInset.left + _backgroundInset.right),
    frame.size.height - (_backgroundInset.top + _backgroundInset.bottom));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _style = nil;
    _backgroundInset = UIEdgeInsetsZero;

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
  CGRect bounds = self.backgroundBounds;

  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.frame = bounds;
  context.contentFrame = bounds;

  if (![self.style draw:context]) {
    [self drawContent:bounds];
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
