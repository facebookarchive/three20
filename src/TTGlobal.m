#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static int gNetworkTaskCount = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color algorithms from http://www.cs.rit.edu/~ncs/color/t_convert.html

#define MAX3(a,b,c) (a > b ? (a > c ? a : c) : (b > c ? b : c))
#define MIN3(a,b,c) (a < b ? (a < c ? a : c) : (b < c ? b : c))

void RGBtoHSV(float r, float g, float b, float* h, float* s, float* v) {
	float min, max, delta;
	min = MIN3(r, g, b);
	max = MAX3(r, g, b);
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////

const void* RetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
void ReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* TTCreateNonRetainingArray() {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = RetainNoOp;
  callbacks.release = ReleaseNoOp;
  return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

BOOL TTEmptyArray(NSObject* object) {
  return [object isKindOfClass:[NSArray class]] && ![(NSArray*)object count];
}

BOOL TTEmptyString(NSObject* object) {
  return [object isKindOfClass:[NSString class]] && ![(NSString*)object length];
}

UIInterfaceOrientation TTDeviceOrientation() {
  UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
  if (!orient) {
    return UIInterfaceOrientationPortrait;
  } else {
    return orient;
  }
}

CGRect TTScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIDeviceOrientationIsLandscape(TTDeviceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}

void TTNetworkRequestStarted() {
  if (gNetworkTaskCount++ == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  }
}

void TTNetworkRequestStopped() {
  if (--gNetworkTaskCount == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSObject (TTCategory)

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 withObject:(id)p5 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo setArgument:&p5 atIndex:6];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo setArgument:&p5 atIndex:6];
    [invo setArgument:&p6 atIndex:7];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 withObject:(id)p7 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo setArgument:&p5 atIndex:6];
    [invo setArgument:&p6 atIndex:7];
    [invo setArgument:&p7 atIndex:8];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

@end

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

- (CGFloat)x {
  return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}

- (CGFloat)y {
  return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
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

- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)screenX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
    x += view.x;
  }
  return x;
}

- (CGFloat)screenY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.y;
  }
  return y;
}

- (CGFloat)screenViewX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
      x += view.x;

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
    y += view.y;

    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      y -= scrollView.contentOffset.y;
    }
  }
  return y;
}

- (CGFloat)orientationWidth {
  return UIDeviceOrientationIsPortrait(TTDeviceOrientation())
    ? self.width : self.height;
}

- (CGFloat)orientationHeight {
  return UIDeviceOrientationIsPortrait(TTDeviceOrientation())
    ? self.height : self.width;
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

- (void)sizeToFitKeyboard:(BOOL)keyboard animated:(BOOL)animated {
  CGRect frame = self.frame;
  if (keyboard) {// && frame.size.height > CONTENT_HEIGHT) {
    frame.size.height -= KEYBOARD_HEIGHT;
  } else {
    frame.size.height += KEYBOARD_HEIGHT;
  }

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  self.frame = frame;
  [UIView commitAnimations];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIWebView (TTCategory)

- (CGRect)frameOfElement:(NSString*)query {
  NSString* result = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
    var target = %@; \
    var x = 0, y = 0; \
    for (var n = target; n && n.nodeType == 1; n = n.offsetParent) {  \
      x += n.offsetLeft; \
      y += n.offsetTop; \
    } \
    x + ',' + y + ',' + target.offsetWidth + ',' + target.offsetHeight; \
", query]];
  
  NSArray* points = [result componentsSeparatedByString:@","];
  CGFloat x = [[points objectAtIndex:0] floatValue];
  CGFloat y = [[points objectAtIndex:1] floatValue];
  CGFloat width = [[points objectAtIndex:2] floatValue];
  CGFloat height = [[points objectAtIndex:3] floatValue];

  return CGRectMake(x, y, width, height);
}

- (void)simulateTapElement:(NSString*)query {
  CGRect frame = [self.window convertRect:self.frame fromView:self.superview];
  CGRect pluginFrame = [self frameOfElement:query];
  CGPoint tapPoint = CGPointMake(
    frame.origin.x + pluginFrame.origin.x + pluginFrame.size.width/3,
    frame.origin.y + pluginFrame.origin.y + pluginFrame.size.height/3
  );
  [self simulateTapAtPoint:tapPoint];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITableView (TTCategory)

- (UIView*)indexView {
  Class indexViewClass = NSClassFromString(@"UITableViewIndex");
  NSEnumerator* e = [self.subviews reverseObjectEnumerator];
  for (UIView* child; child = [e nextObject]; ) {
    if ([child isKindOfClass:indexViewClass]) {
      return child;
    }
  }
  return nil;
}

- (void)touchRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
  if (![self cellForRowAtIndexPath:indexPath]) {
    [self reloadData];
  }
  
  if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
    [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
  }

  [self selectRowAtIndexPath:indexPath animated:animated
    scrollPosition:UITableViewScrollPositionTop];

  if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
    [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
  }
}

- (void)sizeToFitKeyboard:(BOOL)keyboard atIndexPath:(NSIndexPath*)indexPath
    animated:(BOOL)animated {
  [super sizeToFitKeyboard:keyboard animated:animated];
  CGRect frame = self.frame;
  if (keyboard) {// && frame.size.height > CONTENT_HEIGHT) {
    frame.size.height -= KEYBOARD_HEIGHT;
  } else {
    frame.size.height += KEYBOARD_HEIGHT;
  }

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  self.frame = frame;
  [UIView commitAnimations];

  if (indexPath) {
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop
      animated:YES];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIToolbar (TTCategory)

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag {
  for (UIBarButtonItem* button in self.items) {
    if (button.tag == tag) {
      return button;
    }
  }
  return nil;  
}

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item {
  NSInteger index = 0;
  for (UIBarButtonItem* button in self.items) {
    if (button.tag == tag) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.items];
      [newItems replaceObjectAtIndex:index withObject:item];
      self.items = newItems;
      break;
    }
    ++index;
  }
  
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIColor (TTCategory)

- (UIColor*)transformHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd {
  const CGFloat* rgba = CGColorGetComponents(self.CGColor);
  CGFloat r = rgba[0];
  CGFloat g = rgba[1];
  CGFloat b = rgba[2];
  CGFloat a = rgba[3];

  CGFloat h, s, v;
  RGBtoHSV(r, g, b, &h, &s, &v);

  h *= hd;
  v *= vd;
  s *= sd;
  
  HSVtoRGB(&r, &g, &b, h, s, v);
  
  return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIImage (TTCategory)

- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate {
  CGFloat destW = width;
  CGFloat destH = height;
  CGFloat sourceW = width;
  CGFloat sourceH = height;
  if (rotate) {
    if (self.imageOrientation == UIImageOrientationRight
        || self.imageOrientation == UIImageOrientationLeft) {
      sourceW = height;
      sourceH = width;
    }
  }
  
  CGImageRef imageRef = self.CGImage;
  CGContextRef bitmap = CGBitmapContextCreate(NULL, destW, destH,
    CGImageGetBitsPerComponent(imageRef), 4*destW, CGImageGetColorSpace(imageRef),
    CGImageGetBitmapInfo(imageRef));

  if (rotate) {
    if (self.imageOrientation == UIImageOrientationDown) {
      CGContextTranslateCTM(bitmap, sourceW, sourceH);
      CGContextRotateCTM(bitmap, 180 * (M_PI/180));
    } else if (self.imageOrientation == UIImageOrientationLeft) {
      CGContextTranslateCTM(bitmap, sourceH, 0);
      CGContextRotateCTM(bitmap, 90 * (M_PI/180));
    } else if (self.imageOrientation == UIImageOrientationRight) {
      CGContextTranslateCTM(bitmap, 0, sourceW);
      CGContextRotateCTM(bitmap, -90 * (M_PI/180));
    }
  }

  CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);

  CGImageRef ref = CGBitmapContextCreateImage(bitmap);
  UIImage* result = [UIImage imageWithCGImage:ref];
  CGContextRelease(bitmap);
  CGImageRelease(ref);

  return result;
}

@end
