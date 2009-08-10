#import "Three20/TTGlobal.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

static int gNetworkTaskCount = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////

static const void* TTRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void TTReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* TTCreateNonRetainingArray() {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = TTRetainNoOp;
  callbacks.release = TTReleaseNoOp;
  return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

NSMutableDictionary* TTCreateNonRetainingDictionary() {
  CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
  CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
  callbacks.retain = TTRetainNoOp;
  callbacks.release = TTReleaseNoOp;
  return (NSMutableDictionary*)CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks);
}

BOOL TTIsEmptyArray(id object) {
  return [object isKindOfClass:[NSArray class]] && ![(NSArray*)object count];
}

BOOL TTIsEmptySet(id object) {
  return [object isKindOfClass:[NSSet class]] && ![(NSSet*)object count];
}

BOOL TTIsEmptyString(id object) {
  return [object isKindOfClass:[NSString class]] && ![(NSString*)object length];
}

BOOL TTIsKeyboardVisible() {
  UIWindow* window = [UIApplication sharedApplication].keyWindow;
  return !![window performSelector:@selector(firstResponder)];
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

CGRect TTApplicationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

CGRect TTNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TT_ROW_HEIGHT);
}

CGRect TTKeyboardNavigationFrame() {
  return TTRectContract(TTNavigationFrame(), 0, TT_KEYBOARD_HEIGHT);
}

CGRect TTToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TT_ROW_HEIGHT*2);
}

CGFloat TTStatusHeight() {
  return [UIScreen mainScreen].applicationFrame.origin.y;
}

CGFloat TTBarsHeight() {
  return [UIScreen mainScreen].applicationFrame.origin.y + TT_ROW_HEIGHT;
}

CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}

CGRect TTRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(TTRectContract(rect, dx, dy), dx, dy);
}

CGRect TTRectInset(CGRect rect, UIEdgeInsets insets) {
  return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top,
                    rect.size.width - (insets.left + insets.right),
                    rect.size.height - (insets.top + insets.bottom));
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

void TTAlert(NSString* message) {
  UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Alert", @"")
                                             message:message delegate:nil
                                             cancelButtonTitle:TTLocalizedString(@"OK", @"")
                                             otherButtonTitles:nil] autorelease];
  [alert show];
}

void TTAlertError(NSString* message) {
  UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Alert", @"")
                                              message:message delegate:nil
                                              cancelButtonTitle:TTLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil] autorelease];
  [alert show];
}

float TTOSVersion() {
  return [[[UIDevice currentDevice] systemVersion] floatValue];
}

BOOL TTOSVersionIsAtLeast(float version) {
  #ifdef __IPHONE_3_0
    return 3.0 >= version;
  #endif
  #ifdef __IPHONE_2_2
    return 2.2 >= version;
  #endif
  #ifdef __IPHONE_2_1
    return 2.1 >= version;
  #endif
  #ifdef __IPHONE_2_0
    return 2.0 >= version;
  #endif
  return NO;
}

NSLocale* TTCurrentLocale() {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
  if (languages.count > 0) {
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] autorelease];
  } else {
    return [NSLocale currentLocale];
  }
}

NSString* TTLocalizedString(NSString* key, NSString* comment) {
  static NSBundle* bundle = nil;
  if (!bundle) {
    NSString* path = [[[NSBundle mainBundle] resourcePath]
          stringByAppendingPathComponent:@"Three20.bundle"];
    bundle = [[NSBundle bundleWithPath:path] retain];
  }
  
  return [bundle localizedStringForKey:key value:key table:nil];
}

NSString* TTFormatInteger(NSInteger num) {
  NSNumber* number = [NSNumber numberWithInt:num];
  NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:kCFNumberFormatterDecimalStyle];
  [formatter setGroupingSeparator:@","];
  NSString* formatted = [formatter stringForObjectValue:number];
  [formatter release];
  return formatted;
}

NSString* TTDescriptionForError(NSError* error) {
  TTLOG(@"ERROR %@", error);
  if ([error.domain isEqualToString:NSURLErrorDomain]) {
    if (error.code == NSURLErrorTimedOut) {
      return TTLocalizedString(@"Connection Timed Out", @"");
    } else if (error.code == NSURLErrorNotConnectedToInternet) {
      return TTLocalizedString(@"No Internet Connection", @"");
    } else {
      return TTLocalizedString(@"Connection Error", @"");
    }
  }
  return TTLocalizedString(@"Error", @"");
}

BOOL TTIsBundleURL(NSString* URL) {
  if (URL.length >= 9) {
    return [URL rangeOfString:@"bundle://" options:0 range:NSMakeRange(0,9)].location == 0;
  } else {
    return NO;
  }
}

BOOL TTIsDocumentsURL(NSString* URL) {
  if (URL.length >= 12) {
    return [URL rangeOfString:@"documents://" options:0 range:NSMakeRange(0,12)].location == 0;
  } else {
    return NO;
  }
}

NSString* TTPathForBundleResource(NSString* relativePath) {
  NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
  return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* TTPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (!documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsPath = [[dirs objectAtIndex:0] retain];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}

void TTSwapMethods(Class cls, SEL originalSel, SEL newSel) {
  Method originalMethod = class_getInstanceMethod(cls, originalSel);
  Method newMethod = class_getInstanceMethod(cls, newSel);
  method_exchangeImplementations(originalMethod, newMethod);
}
