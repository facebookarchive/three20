/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTGlobal.h"
#import "Three20/TTNavigator.h"
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
  // Operates on the assumption that the keyboard is visible if and only if there is a first
  // responder; i.e. a control responding to key events
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  return !![window findFirstResponder];
}

BOOL TTIsPhoneSupported() {
  NSString *deviceType = [UIDevice currentDevice].model;
  return [deviceType isEqualToString:@"iPhone"];
}

UIDeviceOrientation TTDeviceOrientation() {
  UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
  if (!orient) {
    return UIDeviceOrientationPortrait;
  } else {
    return orient;
  }
}

UIInterfaceOrientation TTInterfaceOrientation() {
  UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
  if (!orient) {
    return [TTNavigator navigator].visibleViewController.interfaceOrientation;
  } else {
    return orient;
  }
}

BOOL TTIsSupportedOrientation(UIInterfaceOrientation orientation) {
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      return YES;
    default:
      return NO;
  }
}

CGAffineTransform TTRotateTransformForOrientation(UIInterfaceOrientation orientation) {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(M_PI*1.5);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(M_PI/2);
  } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformMakeRotation(-M_PI);
  } else {
    return CGAffineTransformIdentity;
  }
}

CGRect TTScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIInterfaceOrientationIsLandscape(TTInterfaceOrientation())) {
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
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TTToolbarHeight());
}

CGRect TTKeyboardNavigationFrame() {
  return TTRectContract(TTNavigationFrame(), 0, TTKeyboardHeight());
}

CGRect TTToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - TTToolbarHeight()*2);
}

CGFloat TTStatusHeight() {
  UIInterfaceOrientation orientation = TTInterfaceOrientation();
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return [UIScreen mainScreen].applicationFrame.origin.x;
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return -[UIScreen mainScreen].applicationFrame.origin.x;
  } else {
    return [UIScreen mainScreen].applicationFrame.origin.y;
  }
}

CGFloat TTBarsHeight() {
  CGRect frame = [UIApplication sharedApplication].statusBarFrame;
  if (UIInterfaceOrientationIsPortrait(TTInterfaceOrientation())) {
    return frame.size.height + TT_ROW_HEIGHT;
  } else {
    return frame.size.width + TT_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}

CGFloat TTToolbarHeight() {
  return TTToolbarHeightForOrientation(TTInterfaceOrientation());
}

CGFloat TTToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    return TT_ROW_HEIGHT;
  } else {
    return TT_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}

CGFloat TTKeyboardHeight() {
  return TTKeyboardHeightForOrientation(TTInterfaceOrientation());
}

CGFloat TTKeyboardHeightForOrientation(UIInterfaceOrientation orientation) {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    return TT_KEYBOARD_HEIGHT;
  } else {
    return TT_LANDSCAPE_KEYBOARD_HEIGHT;
  }
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
  TTDINFO(@"ERROR %@", error);
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
