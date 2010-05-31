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

#import "extThree20CSSStyle/TTCSSStyleSheet.h"

#import "extThree20CSSStyle/TTCSSParser.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"

NSString* kCssPropertyColor = @"color";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTCSSStyleSheet


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(didReceiveMemoryWarning:)
     name: UIApplicationDidReceiveMemoryWarningNotification
     object: nil];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
   removeObserver: self
   name: UIApplicationDidReceiveMemoryWarningNotification
   object: nil];

  TT_RELEASE_SAFELY(_cssStyles);
  TT_RELEASE_SAFELY(_cachedCssStyles);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning:(void*)object {
  [self freeMemory];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CSS Parsing


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadFromFilename:(NSString*)filename {
  TT_RELEASE_SAFELY(_cssStyles);
  TT_RELEASE_SAFELY(_cachedCssStyles);

  BOOL didLoadSuccessfully = NO;

  if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
    TTCSSParser* parser = [[TTCSSParser alloc] init];

    NSDictionary* results = [parser parseFilename:filename];
    TT_RELEASE_SAFELY(parser);

    _cssStyles = [results retain];
    _cachedCssStyles = [[NSMutableDictionary alloc] initWithCapacity:[_cssStyles count]];

    didLoadSuccessfully = YES;
  }

  return didLoadSuccessfully;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Object Cache


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForCssSelector:(NSString*)selector propertyName:(NSString*)propertyName {
  NSDictionary* ruleSet = [_cachedCssStyles objectForKey:selector];
  if (nil != ruleSet) {
    return [ruleSet objectForKey:propertyName];
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObjectForCssSelector: (NSString*)selector
                   propertyName: (NSString*)propertyName
                         object: (id)object {
  TTDASSERT(TTIsStringWithAnyText(selector));
  NSMutableDictionary* ruleSet = [_cachedCssStyles objectForKey:selector];
  if (nil == ruleSet) {
    ruleSet = [[NSMutableDictionary alloc] init];
    [_cachedCssStyles setObject:ruleSet forKey:selector];

    // Can release here because it's now being retained by _processedCssStyles
    [ruleSet release];
  }

  [ruleSet setObject:object forKey:propertyName];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Colors


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)colorFromCssString:(NSString*)cssString {
  UIColor* color = nil;

  if ([cssString characterAtIndex:0] == '#') {
    unsigned long colorValue = 0;

    // #FFF
    if ([cssString length] == 4) {
      colorValue = strtol([cssString UTF8String] + 1, nil, 16);
      colorValue = ((colorValue & 0xF00) << 12) | ((colorValue & 0xF00) << 8)
                   | ((colorValue & 0xF0) << 8) | ((colorValue & 0xF0) << 4)
                   | ((colorValue & 0xF) << 4) | (colorValue & 0xF);

    // #FFFFFF
    } else if ([cssString length] == 7) {
      colorValue = strtol([cssString UTF8String] + 1, nil, 16);
    }

    color = RGBCOLOR(((colorValue & 0xFF0000) >> 16),
                     ((colorValue & 0xFF00) >> 8),
                     (colorValue & 0xFF));
  }

  return color;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)colorWithCssSelector:(NSString*)selector forState:(UIControlState)state {
  NSLog(@"%@", _cssStyles);
  UIColor* color = [self objectForCssSelector:selector propertyName:kCssPropertyColor];

  // No cached value.
  if (nil == color) {
    NSDictionary* ruleSet = [_cssStyles objectForKey:selector];

    // The given selector actually exists in the CSS.
    if (nil != ruleSet) {
      NSArray* values = [ruleSet objectForKey:kCssPropertyColor];

      // There actually are some values.
      if ([values count] > 0) {
        TTDASSERT([values count] == 1); // Shouldn't be more than one value here!
        NSString* colorString = [values objectAtIndex:0];
        color = [self colorFromCssString:colorString];

        // And we can actually parse it.
        if (nil != color) {
          [self setObjectForCssSelector:selector propertyName:kCssPropertyColor object:color];
        }
      }
    }
  }

  return color;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utilities


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)freeMemory {
  TT_RELEASE_SAFELY(_cachedCssStyles);
  _cachedCssStyles = [[NSMutableDictionary alloc] initWithCapacity:[_cssStyles count]];
}


@end

