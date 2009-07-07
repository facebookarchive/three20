#include "Three20/TTLink.h"
#include "Three20/TTAppMap.h"
#include "Three20/TTShape.h"
#include "Three20/TTView.h"
#include "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLink

@synthesize URL = _URL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)linkTouched {
  TTLoadURL(_URL);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _URL = nil;
    _screenView = nil;
    
    [self addTarget:self action:@selector(linkTouched)
          forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_URL);
  TT_RELEASE_MEMBER(_screenView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  if (highlighted) {
    if (!_screenView) {
      _screenView = [[TTView alloc] initWithFrame:self.bounds];
      _screenView.style = TTSTYLE(linkHighlighted);
      _screenView.backgroundColor = [UIColor clearColor];
      _screenView.userInteractionEnabled = NO;
      [self addSubview:_screenView];
    }

    _screenView.frame = self.bounds;
    _screenView.hidden = NO;
  } else {
    _screenView.hidden = YES;
  }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if ([self pointInside:[touch locationInView:self] withEvent:event]) {
    return YES;
  } else {
    self.highlighted = NO;
    return NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setURL:(id)URL {
  [_URL release];
  _URL = [URL retain];
  
  self.userInteractionEnabled = !!_URL;
}

@end
