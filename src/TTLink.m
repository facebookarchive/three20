#include "Three20/TTLink.h"
#include "Three20/TTNavigationCenter.h"
#include "Three20/TTShape.h"
#include "Three20/TTStyledView.h"
#include "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLink

@synthesize url = _url;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _url = nil;
    _screenView = nil;
    
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_screenView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tapped {
  [[TTNavigationCenter defaultCenter] displayObject:_url];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if ([self pointInside:[touch locationInView:self] withEvent:event]) {
    return YES;
  } else {
    self.highlighted = NO;
    return NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  if (!_screenView) {
    _screenView = [[TTStyledView alloc] initWithFrame:self.bounds];
    _screenView.style = TTSTYLE(linkHighlighted);
    _screenView.backgroundColor = [UIColor clearColor];
    _screenView.userInteractionEnabled = NO;
    [self addSubview:_screenView];
  }
  
  if (highlighted) {
    _screenView.frame = self.bounds;
    _screenView.hidden = NO;
  } else {
    _screenView.hidden = YES;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setUrl:(id)url {
  [_url release];
  _url = [url retain];
  
  self.userInteractionEnabled = !!_url;
}

@end
