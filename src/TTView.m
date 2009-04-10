#import "Three20/TTView.h"
#import "Three20/TTStyle.h"
#import "Three20/TTLayout.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTView

@synthesize style = _style, layout = _layout;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _style = nil;
    _layout = nil;
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  [_style release];
  [_layout release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  TTStyle* style = self.style;
  if (style) {
    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.delegate = self;
    context.frame = rect;
    context.contentFrame = rect;

    if (![style draw:context]) {
      [self drawContent:rect];
    }
  } else {
    [self drawContent:rect];
  }
}

- (void)layoutSubviews {
  TTLayout* layout = self.layout;
  if (layout) {
    [layout layoutSubviews:self.subviews forView:self];
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.font = nil;
  return [_style addToSize:CGSizeZero context:context];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)drawContent:(CGRect)rect {
}

@end
