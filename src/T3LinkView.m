// Copyright 2004-2009 Facebook. All Rights Reserved.

#include "Three20/T3LinkView.h"
#include "Three20/T3NavigationCenter.h"
#include "Three20/T3BackgroundView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3LinkView

@synthesize delegate = _delegate, href = _href, borderRadius = _borderRadius;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _href = nil;
    _screenView = nil;
    _borderRadius = 4;
    
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)dealloc {
  [_href release];
  [_screenView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tapped {
  BOOL okToDispatch = YES;
  if ([_delegate respondsToSelector:@selector(linkVisited:link:animated:)]) {
    okToDispatch = (BOOL)(int)[_delegate performSelector:@selector(linkVisited:link:animated:)
      withObject:_href withObject:self withObject:(id)(int)YES];
  }

  if (okToDispatch) {
    [[T3NavigationCenter defaultCenter] displayObject:_href];
  }
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
    _screenView = [[T3BackgroundView alloc] initWithFrame:self.bounds];
    _screenView.background = T3BackgroundRoundedRect;
    _screenView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _screenView.opaque = NO;
    _screenView.contentMode = UIViewContentModeRedraw;
    _screenView.userInteractionEnabled = NO;
    [self addSubview:_screenView];
  }
  
  if (highlighted) {
    _screenView.strokeRadius = _borderRadius;
    _screenView.frame = self.bounds;
    _screenView.hidden = NO;
  } else {
    _screenView.hidden = YES;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setHref:(id)href {
  [_href release];
  _href = [href retain];
  
  self.userInteractionEnabled = !!_href;
}

@end

