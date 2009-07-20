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
  TT_RELEASE_SAFELY(_style);
  TT_RELEASE_SAFELY(_layout);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  TTStyle* style = self.style;
  if (style) {
    TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
    context.delegate = self;
    context.frame = self.bounds;
    context.contentFrame = context.frame;

    [style draw:context];
    if (!context.didDrawContent) {
      [self drawContent:self.bounds];
    }
  } else {
    [self drawContent:self.bounds];
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

- (void)setStyle:(TTStyle*)style {
  if (style != _style) {
    [_style release];
    _style = [style retain];
    
    [self setNeedsDisplay];
  }  
}

- (void)drawContent:(CGRect)rect {
}

@end
