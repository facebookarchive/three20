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

#import "extThree20CSSStyle/TTCSSFunctions.h"
#import "Three20Style/TTGlobalStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTGlobalCorePaths.h"

#define __colorLookupTable [NSDictionary dictionaryWithObjectsAndKeys:\
					 RGBCOLOR(0x00, 0xFF, 0xFF), @"aqua",\
					 [UIColor blackColor], @"black",\
					 RGBCOLOR(0x00, 0x00, 0xFF), @"blue",\
					 RGBCOLOR(0xFF, 0x00, 0xFF), @"fuschia",\
					 RGBCOLOR(0x80, 0x80, 0x80), @"gray",\
					 RGBCOLOR(0x00, 0x80, 0x00), @"green",\
					 RGBCOLOR(0x00, 0xFF, 0x00), @"lime",\
					 RGBCOLOR(0x80, 0x00, 0x00), @"maroon",\
					 RGBCOLOR(0x00, 0x00, 0x80), @"navy",\
					 RGBCOLOR(0x80, 0x80, 0x00), @"olive",\
					 RGBCOLOR(0xFF, 0x00, 0x00), @"red",\
					 RGBCOLOR(0x80, 0x00, 0x80), @"purple",\
					 RGBCOLOR(0xC0, 0xC0, 0xC0), @"silver",\
					 RGBCOLOR(0x00, 0x80, 0x80), @"teal",\
					 RGBACOLOR(0xFF, 0xFF, 0xFF, 0x00), @"transparent",\
					 [UIColor whiteColor], @"white",\
					 RGBCOLOR(0xFF, 0xFF, 0x00), @"yellow",\
					 [UIColor lightTextColor],                @"lightTextColor",\
					 [UIColor darkTextColor],                 @"darkTextColor",\
					 [UIColor groupTableViewBackgroundColor], @"groupTableViewBackgroundColor",\
					 [UIColor viewFlipsideBackgroundColor],   @"viewFlipsideBackgroundColor",\
					 nil]

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Colors
///////////////////////////////////////////////////////////////////////////////////////////////////
UIColor* TTColorFromCssValues( NSArray* cssValues ) {
    UIColor* anColor = nil;

    // Anything more or less is unsupported, and therefore this property is ignored
    // according to the W3C guidelines.
    TTDASSERT([cssValues count] == 1
              || [cssValues count] == 5    // rgb( x x x )
              || [cssValues count] == 6);  // rgba( x x x x )

    if ([cssValues count] == 1) {
        NSString* cssString = [cssValues objectAtIndex:0];

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

            anColor = RGBCOLOR(((colorValue & 0xFF0000) >> 16),
                             ((colorValue & 0xFF00) >> 8),
                             (colorValue & 0xFF));

        } else if ([cssString isEqualToString:@"none"]) {
            anColor = nil;

        } else {
            anColor = [__colorLookupTable objectForKey:cssString];
        }

    } else if ([cssValues count] == 5 && [[cssValues objectAtIndex:0] isEqualToString:@"rgb("]) {
        // rgb( x x x )
        anColor = RGBCOLOR([[cssValues objectAtIndex:1] floatValue],
                         [[cssValues objectAtIndex:2] floatValue],
                         [[cssValues objectAtIndex:3] floatValue]);

    } else if ([cssValues count] == 6 && [[cssValues objectAtIndex:0] isEqualToString:@"rgba("]) {
        // rgba( x x x x )
        anColor = RGBACOLOR([[cssValues objectAtIndex:1] floatValue],
                          [[cssValues objectAtIndex:2] floatValue],
                          [[cssValues objectAtIndex:3] floatValue],
                          [[cssValues objectAtIndex:4] floatValue]);
    }

    return anColor;
}

