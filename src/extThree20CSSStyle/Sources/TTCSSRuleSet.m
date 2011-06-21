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

#import "extThree20CSSStyle/TTCSSRuleSet.h"
#import "extThree20CSSStyle/TTCSSFunctions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTCSSRuleSet
@synthesize selector, font_size, font_family, font_weight;
@synthesize color, background_color, background_image;
@synthesize text_shadow;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init Methods.

///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)initWithSelectorName:(NSString*)anRuleSetName {
    TTCSSRuleSet *instance = [[TTCSSRuleSet new] autorelease];
    instance.selector = anRuleSetName;
    return instance;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
    self = [super init];
    if (self != nil) {

        // Default values.
        self.background_color	  = [UIColor clearColor];
        self.color                = [UIColor clearColor];

		// Font size is the Default Sytem Font Size.
        self.font_size            = [NSNumber numberWithFloat:[UIFont systemFontSize]];

		// Default Font Family.
		self.font_family		  = [[UIFont systemFontOfSize:[UIFont systemFontSize]] familyName];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
    TT_RELEASE_SAFELY( font_family );
    TT_RELEASE_SAFELY( selector );
    TT_RELEASE_SAFELY( font_size );
    TT_RELEASE_SAFELY( font_weight );
    TT_RELEASE_SAFELY( text_shadow );
    TT_RELEASE_SAFELY( color );
    TT_RELEASE_SAFELY( background_color );
    TT_RELEASE_SAFELY( background_image );
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Set Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setUIColorProperty:(UIColor**)anColor withValue:(id)anValue {

	/////////////////////////////////
	// Release.
	if ( *anColor )
		TT_RELEASE_SAFELY( *anColor );

	///////////////////////////////////////
    // Array of color?
	if ( [anValue isKindOfClass:[NSArray class]] ) {

		// Set.
        *anColor = [TTColorFromCssValues(anValue) retain];

	}

    ///////////////////////////////////////
    // String color?
    else if ( [anValue isKindOfClass:[NSString class]] ) {

        // Set.
        *anColor = [TTColorFromCssValues([NSArray arrayWithObject:anValue]) retain];
    }

    ///////////////////////////////////////
    // UIColor?
    else if ( [anValue isKindOfClass:[UIColor class]] ) {

		// Set.
        *anColor = [anValue retain];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setColor:(id)anColor {
	[self setUIColorProperty:&color withValue:anColor];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setBackground_color:(id)anColor {
	[self setUIColorProperty:&background_color withValue:anColor];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Data Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Return an formatted UIFont object based on the defined properties.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIFont*)font {
    // If not enough properties return nil.
    if ( !font_family && !font_size ) {
        TTDWARNING ( @"Can't format UIFont, 'font_family' or 'font_size' isn't defined." );
        return nil;
    }

    //////////////////////////////////
    // Font weight.
    NSString *fullFontWeight = ( font_weight == nil
								? @""
								: [NSString stringWithFormat:@"-%@", font_weight] );

    //////////////////////////////////
    // Font Name.
    NSString *fullFontName = [NSString stringWithFormat:@"%@%@", font_family,
							  fullFontWeight];

    //////////////////////////////////
    // Create and return UIFont.
    return [UIFont fontWithName:fullFontName size:[font_size floatValue]];
}

@end
