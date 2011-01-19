//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/private/TTLauncherHighlightView.h"

// UI
#import "Three20UI/TTLauncherButton.h"
#import "Three20UI/TTLauncherView.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kHighlightOverlayAlpha = 0.7f;
static const CGFloat kSpotlightScaleFactor = 2.5f;
static const CGFloat kSpotlightBlurInnerAlpha = 0.43f;
static const CGFloat kSpotlightBlurOuterAlpha = 0.7f;  // same as kHighlightOverlayAlpha; grr const
static const CGFloat kSpotlightBlurRadius = 120.0f;
static const CGFloat kHighlightTextPadding = 20.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLauncherHighlightView

@synthesize highlightRect = _highlightRect;
@synthesize parentView    = _parentView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.alpha = 0.0;

    _textLabel = [[UILabel alloc] init];
    _textLabel.lineBreakMode = UILineBreakModeWordWrap;
    _textLabel.numberOfLines = 0;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textAlignment = UITextAlignmentCenter;
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    _textLabel.shadowColor = [UIColor blackColor];
    _textLabel.shadowOffset = CGSizeMake(1, 1);

    [self addSubview:_textLabel];

    CGRect coverFrame = [UIApplication sharedApplication].statusBarFrame;
    _statusBarCover = [[UIWindow alloc] initWithFrame:coverFrame];
    _statusBarCover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:kHighlightOverlayAlpha];
    _statusBarCover.windowLevel = UIWindowLevelStatusBar;
    _statusBarCover.alpha = 0.0;
    _statusBarCover.hidden = NO;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_textLabel);
  TT_RELEASE_SAFELY(_statusBarCover);
  self.parentView = nil;

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animateTextIn {
  _textLabel.alpha = 0.0;

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
  _textLabel.alpha = 1.0;
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutLabel {
  CGSize superviewSize = self.superview.bounds.size;
  CGFloat width = superviewSize.width - 2 * kHighlightTextPadding;
  CGFloat height = [_textLabel.text sizeWithFont:_textLabel.font
                               constrainedToSize:CGSizeMake(width, superviewSize.height)].height;

  // If the highlighted rect is above center, put the text below it; otherwise, above it.
  CGFloat y = 0.0;
  if (_highlightRect.origin.y + (_highlightRect.size.height / 2) < superviewSize.height / 2) {
    y = _highlightRect.origin.y + _highlightRect.size.height + kHighlightTextPadding;
  } else {
    y = _highlightRect.origin.y - height - kHighlightTextPadding;
  }

  _textLabel.frame = CGRectMake(kHighlightTextPadding, y, width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightRect:(CGRect)rect {
  _highlightRect = rect;
  [self layoutLabel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)text {
  return _textLabel.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
  _textLabel.text = text;
  [self layoutLabel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAlpha:(CGFloat)alpha {
  [super setAlpha:alpha];
  _statusBarCover.alpha = alpha;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)appear:(BOOL)animated {
  // The expanded frame needs to be 3.5 times the original size, and the expansion needs to emanate
  // from the same center as the highlighted rect
  CGRect expandedFrame = self.superview.bounds;
  expandedFrame.origin.x = -(_highlightRect.origin.x + _highlightRect.size.width / 2)
  * (kSpotlightScaleFactor - 1);
  expandedFrame.origin.y = -(_highlightRect.origin.y + _highlightRect.size.height / 2)
  * (kSpotlightScaleFactor - 1);
  expandedFrame.size.width *= kSpotlightScaleFactor;
  expandedFrame.size.height *= kSpotlightScaleFactor;
  self.frame = expandedFrame;
  self.alpha = 0.0;
  _textLabel.alpha = 0.0;

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateTextIn)];
  }
  self.alpha = 1.0;
  self.frame = self.superview.bounds;
  _statusBarCover.alpha = 1.0;

  if (animated) {
    [UIView commitAnimations];
  } else {
    _textLabel.alpha = 1.0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOpaque {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kHighlightOverlayAlpha] set];
  UIRectFillUsingBlendMode(rect, kCGBlendModeOverlay);

  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetBlendMode(context, kCGBlendModeCopy);

  // Draw the spotlight (more of a Fresnel lens effect but okay I'll stop now)
  const CGFloat components[] = {0, 0, 0, kSpotlightBlurInnerAlpha,
                                0, 0, 0, kSpotlightBlurOuterAlpha};
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
  CGPoint center = CGPointMake(floor(_highlightRect.origin.x + _highlightRect.size.width / 2),
                               floor(_highlightRect.origin.y + _highlightRect.size.height / 2));
  CGFloat startRadius = MIN(_highlightRect.size.width, _highlightRect.size.height) / 2;
  CGFloat endRadius = startRadius + kSpotlightBlurRadius;
  CGContextDrawRadialGradient(context,
                              gradient,
                              center, startRadius,
                              center, endRadius,
                              kCGGradientDrawsAfterEndLocation);
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);

  // Draw the clear circle
  CGContextSetRGBFillColor(context, 0, 0, 0, 0);
  CGContextFillEllipseInRect(context, _highlightRect);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Overridden so that -hitTest:withEvent: doesn't catch this subview. We can distinguish a user-
 * initiated tap from a programmatic hit test by event being nil in the programmatic case.
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
  if (event) {
    return [super pointInside:point withEvent:event];
  }

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent*)event {
  UITouch* touch = [touches anyObject];

  // If the user tapped within the highlighted rect, we want to pass the event through to the
  // launcher button.
  if (CGRectContainsPoint(_highlightRect, [touch locationInView:self])) {
    UIView *targetButton = [self.superview hitTest:[touch locationInView:self] withEvent:nil];

    // This condition should always be true, but just to be safe
    if ([targetButton isKindOfClass:[TTLauncherButton class]]) {
      [(TTLauncherButton *)targetButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
  }

  // This will take care of removing the view
  [_parentView endHighlightItem:nil];
}


@end
