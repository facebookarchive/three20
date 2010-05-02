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

#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"


// Remove GSEvent and UITouchAdditions from Release builds
#ifdef DEBUG

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A private API class used for synthesizing touch events. This class is compiled out of release
 * builds.
 *
 * This code for synthesizing touch events is derived from:
 * http://cocoawithlove.com/2008/10/synthesizing-touch-event-on-iphone.html
 */
@interface GSEventFake : NSObject {
  @public
  int ignored1[5];
  float x;
  float y;
  int ignored2[24];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GSEventFake
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface UIEventFake : NSObject {
  @public
  CFTypeRef               _event;
  NSTimeInterval          _timestamp;
  NSMutableSet*           _touches;
  CFMutableDictionaryRef  _keyedTouches;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIEventFake

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface UITouch (TTCategory)

- (id)initInView:(UIView *)view location:(CGPoint)location;
- (void)changeToPhase:(UITouchPhase)phase;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UITouch (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initInView:(UIView *)view location:(CGPoint)location {
  if (self = [super init]) {
    _tapCount = 1;
    _locationInWindow = location;
    _previousLocationInWindow = location;

    UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
    _view = [target retain];
    _window = [view.window retain];
    _phase = UITouchPhaseBegan;
    _touchFlags._firstTouchForView = 1;
    _touchFlags._isTap = 1;
    _timestamp = [NSDate timeIntervalSinceReferenceDate];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)changeToPhase:(UITouchPhase)phase {
  _phase = phase;
  _timestamp = [NSDate timeIntervalSinceReferenceDate];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIEvent (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTouch:(UITouch *)touch {
  if (self == [super init]) {
    UIEventFake *selfFake = (UIEventFake*)self;
    selfFake->_touches = [[NSMutableSet setWithObject:touch] retain];
    selfFake->_timestamp = [NSDate timeIntervalSinceReferenceDate];

    CGPoint location = [touch locationInView:touch.window];
    GSEventFake* fakeGSEvent = [[GSEventFake alloc] init];
    fakeGSEvent->x = location.x;
    fakeGSEvent->y = location.y;
    selfFake->_event = fakeGSEvent;

    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 2,
      &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(dict, touch.view, selfFake->_touches);
    CFDictionaryAddValue(dict, touch.window, selfFake->_touches);
    selfFake->_keyedTouches = dict;
  }
  return self;
}


@end

#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIView (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
  return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
  return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
  CGRect frame = self.frame;
  frame.origin.x = right - frame.size.width;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
  CGRect frame = self.frame;
  frame.origin.y = bottom - frame.size.height;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
  return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
  self.center = CGPointMake(centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
  return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
  self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
  return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
  return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
    x += view.left;
  }
  return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;
  }
  return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
      x += view.left;

    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      x -= scrollView.contentOffset.x;
    }
  }

  return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;

    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      y -= scrollView.contentOffset.y;
    }
  }
  return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)screenFrame {
  return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
  return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
  CGRect frame = self.frame;
  frame.origin = origin;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
  return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
  CGRect frame = self.frame;
  frame.size = size;
  self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)orientationWidth {
  return UIInterfaceOrientationIsLandscape(TTInterfaceOrientation())
    ? self.height : self.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)orientationHeight {
  return UIInterfaceOrientationIsLandscape(TTInterfaceOrientation())
    ? self.width : self.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)descendantOrSelfWithClass:(Class)cls {
  if ([self isKindOfClass:cls])
    return self;

  for (UIView* child in self.subviews) {
    UIView* it = [child descendantOrSelfWithClass:cls];
    if (it)
      return it;
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)ancestorOrSelfWithClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else if (self.superview) {
    return [self.superview ancestorOrSelfWithClass:cls];
  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
  while (self.subviews.count) {
    UIView* child = self.subviews.lastObject;
    [child removeFromSuperview];
  }
}


#ifdef DEBUG

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)simulateTapAtPoint:(CGPoint)location {
  UITouch *touch = [[[UITouch alloc] initInView:self location:location] autorelease];

  UIEvent *eventDown = [[[UIEvent alloc] initWithTouch:touch] autorelease];
  [touch.view touchesBegan:[NSSet setWithObject:touch] withEvent:eventDown];

  [touch changeToPhase:UITouchPhaseEnded];

  UIEvent *eventUp = [[[UIEvent alloc] initWithTouch:touch] autorelease];
  [touch.view touchesEnded:[NSSet setWithObject:touch] withEvent:eventUp];
}

#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)offsetFromView:(UIView*)otherView {
  CGFloat x = 0, y = 0;
  for (UIView* view = self; view && view != otherView; view = view.superview) {
    x += view.left;
    y += view.top;
  }
  return CGPointMake(x, y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameWithKeyboardSubtracted:(CGFloat)plusHeight {
  CGRect frame = self.frame;
  if (TTIsKeyboardVisible()) {
    CGRect screenFrame = TTScreenBounds();
    CGFloat keyboardTop = (screenFrame.size.height - (TTKeyboardHeight() + plusHeight));
    CGFloat screenBottom = self.ttScreenY + frame.size.height;
    CGFloat diff = screenBottom - keyboardTop;
    if (diff > 0) {
      frame.size.height -= diff;
    }
  }
  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)userInfoForKeyboardNotification {
  CGRect screenFrame = TTScreenBounds();
  CGRect bounds = CGRectMake(0, 0, screenFrame.size.width, self.height);
  CGPoint centerBegin = CGPointMake(floor(screenFrame.size.width/2 - self.width/2),
                                    screenFrame.size.height + floor(self.height/2));
  CGPoint centerEnd = CGPointMake(floor(screenFrame.size.width/2 - self.width/2),
                                  screenFrame.size.height - floor(self.height/2));

  return [NSDictionary dictionaryWithObjectsAndKeys:
          [NSValue valueWithCGRect:bounds], UIKeyboardBoundsUserInfoKey,
          [NSValue valueWithCGPoint:centerBegin], UIKeyboardCenterBeginUserInfoKey,
          [NSValue valueWithCGPoint:centerEnd], UIKeyboardCenterEndUserInfoKey,
          nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentAsKeyboardAnimationDidStop {
  [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidShowNotification
                                                      object:self
                                                    userInfo:[self userInfoForKeyboardNotification]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAsKeyboardAnimationDidStop {
  [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification
                                                      object:self
                                                    userInfo:[self userInfoForKeyboardNotification]];
  [self removeFromSuperview];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)presentAsKeyboardInView:(UIView*)containingView {
  [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillShowNotification
                                                      object:self
                                                    userInfo:[self userInfoForKeyboardNotification]];

  self.top = containingView.height;
  [containingView addSubview:self];

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(presentAsKeyboardAnimationDidStop)];
  self.top -= self.height;
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAsKeyboard:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification
                                                      object:self
                                                    userInfo:[self userInfoForKeyboardNotification]];

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAsKeyboardAnimationDidStop)];
  }

  self.top += self.height;

  if (animated) {
    [UIView commitAnimations];
  } else {
    [self dismissAsKeyboardAnimationDidStop];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)viewController {
  for (UIView* next = [self superview]; next; next = next.superview) {
    UIResponder* nextResponder = [next nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController*)nextResponder;
    }
  }
  return nil;
}


@end
