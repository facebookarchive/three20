#import "Three20/TTGlobal.h"

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

BOOL TTIsEmptyArray(NSObject* object) {
  return [object isKindOfClass:[NSArray class]] && ![(NSArray*)object count];
}

BOOL TTIsEmptyString(NSObject* object) {
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

CGRect TTApplicationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

CGRect TTNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TOOLBAR_HEIGHT);
}

CGRect TTToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TOOLBAR_HEIGHT*2);
}

CGRect TTRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
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

BOOL TTIsBundleURL(NSString* url) {
  if (url.length >= 9) {
    return [url rangeOfString:@"bundle://" options:0 range:NSMakeRange(0,9)].location == 0;
  } else {
    return NO;
  }
}

BOOL TTIsDocumentsURL(NSString* url) {
  if (url.length >= 12) {
    return [url rangeOfString:@"documents://" options:0 range:NSMakeRange(0,12)].location == 0;
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
