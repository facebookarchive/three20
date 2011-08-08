//
// Copyright 2009-2011 Facebook
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
#import "extThree20CSSStyle/TTCSSRuleSet.h"
#import "extThree20CSSStyle/TTDataPopulator.h"
#import "extThree20CSSStyle/TTDataConverter.h"

#import "extThree20CSSStyle/TTCSSParser.h"


// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"

NSString* kCssPropertyColor           = @"color";
NSString* kCssPropertyBackgroundColor = @"background-color";
NSString* kCssPropertyFont            = @"font";
NSString* kCssPropertyFontSize        = @"font-size";
NSString* kCssPropertyFontWeight      = @"font-weight";
NSString* kCssPropertyFontFamily      = @"font-family";
NSString* kCssPropertyTextShadow      = @"text-shadow";

// Text shadow keys
NSString* kKeyTextShadowHOffset = @"hoffset";
NSString* kKeyTextShadowVOffset = @"voffset";
NSString* kKeyTextShadowBlur    = @"blur";
NSString* kKeyTextShadowColor   = @"color";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTCSSStyleSheet

@synthesize cssStyles = _cssStyles;
@synthesize cssRulesSet = _cssRulesSet;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
  if (self) {
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

  TT_RELEASE_SAFELY(_cssRulesSet);
  TT_RELEASE_SAFELY(_cssStyles);
  TT_RELEASE_SAFELY(_propertiesMap);
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
  TT_RELEASE_SAFELY(_cssRulesSet);

  BOOL didLoadSuccessfully = NO;

  if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
    TTCSSParser* parser = [[TTCSSParser alloc] init];

    NSDictionary* results = [parser parseFilename:filename];
    TT_RELEASE_SAFELY(parser);

    _cssStyles	 = [results retain];
    _cssRulesSet = [[NSMutableDictionary alloc] initWithCapacity:[_cssStyles count]];

    didLoadSuccessfully = YES;
  }

  return didLoadSuccessfully;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addStyleSheet:(TTCSSStyleSheet*)styleSheet {
  TTDASSERT(nil != styleSheet);
  if (nil == styleSheet) {
    return;
  }

  // Clear the cache first.
  TT_RELEASE_SAFELY(_cssRulesSet);
  _cssRulesSet = [[NSMutableDictionary alloc] initWithCapacity:[_cssStyles count]];

   // Should init the styles?
   if ( !_cssStyles )
      _cssStyles = [NSDictionary new];

   NSMutableDictionary* newStyles = [_cssStyles mutableCopy];

  for (NSString* selector in styleSheet.cssStyles) {
    NSDictionary* addingRuleSet   = [styleSheet.cssStyles objectForKey:selector];
    NSDictionary* existingRuleSet = [_cssStyles objectForKey:selector];

    if (nil == existingRuleSet) {
      // Easiest case where the old style sheet doesn't have the rule set, we just add it.
      [newStyles setObject:addingRuleSet forKey:selector];
      continue;
    }

    if ([addingRuleSet count] > 0) {
      NSMutableDictionary* newRuleSet = [existingRuleSet mutableCopy];
      [newRuleSet addEntriesFromDictionary:addingRuleSet];

      [newStyles setObject:newRuleSet forKey:selector];
      TT_RELEASE_SAFELY(newRuleSet);
    }
  }

  TT_RELEASE_SAFELY(_cssStyles);
  _cssStyles = newStyles;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Populate Methods.

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionary*)propertiesMap {
	if ( !_propertiesMap ) {
		_propertiesMap = [[NSDictionary dictionaryWithObjectsAndKeys:
								@"color",				@"color",
								@"font_family",			@"font",
								@"font_family",			@"font-family",
								@"font_weight",			@"font-weight",
								@"font_size",			@"font-size",
								@"background_color",	@"background-color",
								@"background_image",	@"background-image",
								@"text_shadow",			@"text-shadow",
								@"text_align",			@"text-align",
                                @"width",               @"width",
                                @"visibility",          @"visibility",
                                @"height",              @"height",
                                @"top",                 @"top",
                                @"left",                @"left",
                                @"right",               @"right",
                                @"bottom",              @"bottom",
                                @"text_shadow_opacity", @"text-shadow-opacity",
                                @"margin_left",         @"margin-left",
                                @"margin_right",        @"margin-right",
                                @"vertical_align",      @"vertical-align",

						  nil] retain];
	}
	return _propertiesMap;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// When the Data Populator can't automatically convert some specific type. He will call
// this method and let you extend the class converting you specific type.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)tryToConvert:(id)object ofClass:(Class)objectClass toClass:(Class)convertToClass {

	///////// /////// /////// /////// /////// /////// /////// /////// /////// ///////
	// Text Shadow Model.
	if ( convertToClass == [TTCSSTextShadowModel class] ) {

		// Anything more or less is unsupported, and therefore this property is ignored
		// according to the W3C guidelines.
		NSArray* values = object;
		TTDASSERT([values count] >= 4);
		if ([values count] >= 4) {
			TTCSSTextShadowModel *shadowModel;
			// Create an Shadow Model from data and return.
			shadowModel = [TTCSSTextShadowModel initWithShadowColor:[values subarrayWithRange:
															  NSMakeRange(3,[values count] - 3)]
											 andShadowOffset:CGSizeMake([[values objectAtIndex:0] floatValue],
																		[[values objectAtIndex:1] floatValue])
													  andShadowBlur:[values objectAtIndex:3]];
			// Return.
			return shadowModel;
		}
	}

    ///////// /////// /////// /////// /////// /////// /////// /////// /////// ///////
	// Strings.
	if ( convertToClass == [NSString class] ) {
        if ( [object isKindOfClass:[NSArray class]] ) {
            NSMutableString *merged = [NSMutableString string];
            for ( NSString* part in object ) {
                [merged appendString:part];
            }
            // Return merged.
            return merged;
        }
        else if ( [object isKindOfClass:[NSString class]] ) {
            return object;
        }
        else {
            return nil;
        }
    }

	///////// /////// /////// /////// /////// /////// /////// /////// /////// ///////
	// Some crude data is returned as an NSArray...
	if ( [object isKindOfClass:[NSArray class]] ) {

		// If have more than one element, return the full array.
		if ( [object count] > 1 )
			return object;

		// If not, we just need the first element.
		id element = [object objectAtIndex:0];

		// Only one parameter is NSNumber, is the size of the font. Sometimes
		// this value come with a 'pt' on it.
		// We don't need it right? So we clean the string and convert to NSNumber.
		if ( convertToClass == [NSNumber class] ) {

			// Clean it.
			element = [(NSString*)element stringByReplacingOccurrencesOfString:@"pt"
																	withString:@""];
			// Convert to number.
			return [TTDataConverter convertToNSNumberThisObject:element];
		}

		// Return the element.
		return element;
	}

	// If can't convert. Return nil.
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)selector:(NSString*)selector forState:(UIControlState)state {
	switch (state) {
		default:
		case UIControlStateNormal:
			break;

		case UIControlStateHighlighted: {
			selector = [selector stringByAppendingString:@":hover"];
			break;
		}
	}

	return selector;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Object Cache

///////////////////////////////////////////////////////////////////////////////////////////////////
-(TTCSSRuleSet*)css:(NSString*)selector {
	TTCSSRuleSet *ruleSet = [_cssRulesSet objectForKey:selector];

	////////////////////////////////////////////////////
	// Can't find? Try to create it.
	if ( ruleSet == nil ) {

		////////////////////////////////////////////////////
		// Retrieve from "crude" repository?
		NSDictionary *crudeData = [_cssStyles objectForKey:selector];

		// Don't exist? Warn and return nil.
		if ( !crudeData ) {
			TTDWARNING( @"The CSS selector '%@' don't exist.", selector );
			return nil;
		}

		// Create it.
		ruleSet = [TTCSSRuleSet initWithSelectorName:selector];

		// Populate
		ruleSet = [TTDataPopulator populateObject:ruleSet
										 withData:crudeData
										 usingMap:[self propertiesMap]
									 withDelegate:self];

		// Cache it.
		[_cssRulesSet setValue:ruleSet forKey:selector];
	}

	// Return it.
	return ruleSet;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(TTCSSRuleSet*)css:(NSString*)selectorName forState:(UIControlState)state {
	return [self css:[self selector:selectorName forState:state]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Colors

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)colorWithCssSelector:(NSString*)selector forState:(UIControlState)state {
  	// Try Retrieve Rule Set from Cache.
	TTCSSRuleSet *ruleSet = [self css:selector forState:state];

	// If don't have an CSS Rule Set, return nil.
	if ( !ruleSet ) return nil;

	// Return color from rule set.
	return ruleSet.color;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)colorWithCssSelector:(NSString*)selector {
	return [self colorWithCssSelector:selector forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)backgroundColorWithCssSelector:(NSString*)selector forState:(UIControlState)state {
	// Try Retrieve Rule Set from Cache.
	TTCSSRuleSet *ruleSet = [self css:selector forState:state];

	// If don't have an CSS Rule Set, return nil.
	if ( !ruleSet ) return nil;

	// Return background color from rule set.
	return ruleSet.background_color;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)backgroundColorWithCssSelector:(NSString*)selector {
	return [self backgroundColorWithCssSelector:selector forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Fonts

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)fontWithCssSelector:(NSString*)selector forState:(UIControlState)state {

    // Try Retrieve Rule Set from Cache.
    TTCSSRuleSet *ruleSet = [self css:selector forState:state];

    // If don't have an CSS Rule Set, return nil.
    if ( !ruleSet ) return nil;

    // Return decoded font from rule set.
    return ruleSet.font;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)fontWithCssSelector:(NSString*)selector {
	return [self fontWithCssSelector:selector forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Text Shadows

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textShadowColorWithCssSelector:(NSString*)selector forState:(UIControlState)state {
	// Try Retrieve Rule Set from Cache.
	TTCSSRuleSet *ruleSet = [self css:selector forState:state];

	// If don't have an CSS Rule Set, return nil.
	if ( !ruleSet ) return nil;

	// Return Text Shadow Color.
	return ruleSet.text_shadow.shadowColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textShadowColorWithCssSelector:(NSString*)selector {
	return [self textShadowColorWithCssSelector:selector forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)textShadowOffsetWithCssSelector:(NSString*)selector forState:(UIControlState)state {
  // Try Retrieve Rule Set from Cache.
	TTCSSRuleSet *ruleSet = [self css:selector forState:state];

	// If don't have an CSS Rule Set, return zero.
	if ( !ruleSet ) return CGSizeZero;

	// Return Text Shadow Color.
	return ruleSet.text_shadow.shadowOffset;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)textShadowOffsetWithCssSelector:(NSString*)selector {
	return [self textShadowOffsetWithCssSelector:selector forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)textShadowRadiusWithCssSelector:(NSString*)selector forState:(UIControlState)state {
  // Try Retrieve Rule Set from Cache.
	TTCSSRuleSet *ruleSet = [self css:selector forState:state];

	// If don't have an CSS Rule Set, return zero.
	if ( !ruleSet ) return 0.0;

	// Return Shadow Blur.
  return [[ruleSet.text_shadow shadowBlur] floatValue];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)textShadowRadiusWithCssSelector:(NSString*)selector {
  return [self textShadowRadiusWithCssSelector:selector forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utilities


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)freeMemory {
  TT_RELEASE_SAFELY(_cssRulesSet);
  _cssRulesSet = [[NSMutableDictionary alloc] initWithCapacity:[_cssStyles count]];
}


@end

