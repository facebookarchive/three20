#include "Three20/TTLink.h"
#include "Three20/TTNavigationCenter.h"
#include "Three20/TTShape.h"
#include "Three20/TTView.h"
#include "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLink

@synthesize url = _url;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)linkTouched {
  [[TTNavigationCenter defaultCenter] displayObject:_url];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _url = nil;
    _screenView = nil;
    
    [self addTarget:self action:@selector(linkTouched)
          forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_screenView release];
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

- (void)setUrl:(id)url {
  [_url release];
  _url = [url retain];
  
  self.userInteractionEnabled = !!_url;
}

@end
