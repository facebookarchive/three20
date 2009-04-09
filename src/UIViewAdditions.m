#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// This code for synthesizing touch events is derived from:
// http://cocoawithlove.com/2008/10/synthesizing-touch-event-on-iphone.html

@interface GSEventFake : NSObject {
  @public
  int ignored1[5];
  float x;
  float y;
  int ignored2[24];
}
@end

@implementation GSEventFake
@end

@interface UIEventFake : NSObject {
  @public
  CFTypeRef _event;
  NSTimeInterval _timestamp;
  NSMutableSet* _touches;
  CFMutableDictionaryRef _keyedTouches;
}
@end

@implementation UIEventFake
@end

@interface UITouch (TTCategory)

- (id)initInView:(UIView *)view location:(CGPoint)location;
- (void)changeToPhase:(UITouchPhase)phase;

@end

@implementation UITouch (TTCategory)

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

- (void)changeToPhase:(UITouchPhase)phase {
  _phase = phase;
  _timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end

@implementation UIEvent (TTCategory)

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

@implementation UIView (TTCategory)

- (CGFloat)left {
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}

- (CGFloat)top {
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}

- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}

- (CGFloat)screenX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
    x += view.left;
  }
  return x;
}

- (CGFloat)screenY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;
  }
  return y;
}

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

- (CGPoint)offsetFromView:(UIView*)otherView {
  CGFloat x = 0, y = 0;
  for (UIView* view = self; view && view != otherView; view = view.superview) {
    x += view.left;
    y += view.top;
  }
  return CGPointMake(x, y);
}

- (CGFloat)orientationWidth {
  return UIDeviceOrientationIsLandscape(TTDeviceOrientation())
    ? self.height : self.width;
}

- (CGFloat)orientationHeight {
  return UIDeviceOrientationIsLandscape(TTDeviceOrientation())
    ? self.width : self.height;
}

- (UIScrollView*)findFirstScrollView {
  if ([self isKindOfClass:[UIScrollView class]])
    return (UIScrollView*)self;
  
  for (UIView* child in self.subviews) {
    UIScrollView* it = [child findFirstScrollView];
    if (it)
      return it;
  }
  
  return nil;
}

- (UIView*)firstViewOfClass:(Class)cls {
  if ([self isKindOfClass:cls])
    return self;
  
  for (UIView* child in self.subviews) {
    UIView* it = [child firstViewOfClass:cls];
    if (it)
      return it;
  }
  
  return nil;
}

- (UIView*)firstParentOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else if (self.superview) {
    return [self.superview firstParentOfClass:cls];
  } else {
    return nil;
  }
}

- (UIView*)findChildWithDescendant:(UIView*)descendant {
  for (UIView* view = descendant; view && view != self; view = view.superview) {
    if (view.superview == self) {
      return view;
    }
  }
  
  return nil;
}

- (void)removeSubviews {
  while (self.subviews.count) {
    UIView* child = self.subviews.lastObject;
    [child removeFromSuperview];
  }
}

- (void)simulateTapAtPoint:(CGPoint)location {
  UITouch *touch = [[[UITouch alloc] initInView:self location:location] autorelease];

  UIEvent *eventDown = [[[UIEvent alloc] initWithTouch:touch] autorelease];
  [touch.view touchesBegan:[NSSet setWithObject:touch] withEvent:eventDown];

  [touch changeToPhase:UITouchPhaseEnded];

  UIEvent *eventUp = [[[UIEvent alloc] initWithTouch:touch] autorelease];
  [touch.view touchesEnded:[NSSet setWithObject:touch] withEvent:eventUp];
}

@end
