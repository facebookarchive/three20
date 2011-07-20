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
#import "extThree20CSSStyle/TTDataConverter.h"
#import "Three20Style/TTGlobalStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTGlobalCorePaths.h"


// CSS3 Color Lookuptable (4.3. Extended color keywords): http://www.w3.org/TR/css3-color/#svg-color
#define __colorLookupTable [NSDictionary dictionaryWithObjectsAndKeys:\
					RGBCOLOR(0xFF, 0x00, 0xFF), @"fuschia",\
					RGBCOLOR(240,248,255), @"aliceblue",\
					RGBCOLOR(250,235,215), @"antiquewhite",\
					RGBCOLOR(0,255,255), @"aqua",\
					RGBCOLOR(127,255,212), @"aquamarine",\
					RGBCOLOR(240,255,255), @"azure",\
					RGBCOLOR(245,245,220), @"beige",\
					RGBCOLOR(255,228,196), @"bisque",\
					RGBCOLOR(0,0,0), @"black",\
					RGBCOLOR(255,235,205), @"blanchedalmond",\
					RGBCOLOR(0,0,255), @"blue",\
					RGBCOLOR(138,43,226), @"blueviolet",\
					RGBCOLOR(165,42,42), @"brown",\
					RGBCOLOR(222,184,135), @"burlywood",\
					RGBCOLOR(95,158,160), @"cadetblue",\
					RGBCOLOR(127,255,0), @"chartreuse",\
					RGBCOLOR(210,105,30), @"chocolate",\
					RGBCOLOR(255,127,80), @"coral",\
					RGBCOLOR(100,149,237), @"cornflowerblue",\
					RGBCOLOR(255,248,220), @"cornsilk",\
					RGBCOLOR(220,20,60), @"crimson",\
					RGBCOLOR(0,255,255), @"cyan",\
					RGBCOLOR(0,0,139), @"darkblue",\
					RGBCOLOR(0,139,139), @"darkcyan",\
					RGBCOLOR(184,134,11), @"darkgoldenrod",\
					RGBCOLOR(169,169,169), @"darkgray",\
					RGBCOLOR(0,100,0), @"darkgreen",\
					RGBCOLOR(169,169,169), @"darkgrey",\
					RGBCOLOR(189,183,107), @"darkkhaki",\
					RGBCOLOR(139,0,139), @"darkmagenta",\
					RGBCOLOR(85,107,47), @"darkolivegreen",\
					RGBCOLOR(255,140,0), @"darkorange",\
					RGBCOLOR(153,50,204), @"darkorchid",\
					RGBCOLOR(139,0,0), @"darkred",\
					RGBCOLOR(233,150,122), @"darksalmon",\
					RGBCOLOR(143,188,143), @"darkseagreen",\
					RGBCOLOR(72,61,139), @"darkslateblue",\
					RGBCOLOR(47,79,79), @"darkslategray",\
					RGBCOLOR(47,79,79), @"darkslategrey",\
					RGBCOLOR(0,206,209), @"darkturquoise",\
					RGBCOLOR(148,0,211), @"darkviolet",\
					RGBCOLOR(255,20,147), @"deeppink",\
					RGBCOLOR(0,191,255), @"deepskyblue",\
					RGBCOLOR(105,105,105), @"dimgray",\
					RGBCOLOR(105,105,105), @"dimgrey",\
					RGBCOLOR(30,144,255), @"dodgerblue",\
					RGBCOLOR(178,34,34), @"firebrick",\
					RGBCOLOR(255,250,240), @"floralwhite",\
					RGBCOLOR(34,139,34), @"forestgreen",\
					RGBCOLOR(255,0,255), @"fuchsia",\
					RGBCOLOR(220,220,220), @"gainsboro",\
					RGBCOLOR(248,248,255), @"ghostwhite",\
					RGBCOLOR(255,215,0), @"gold",\
					RGBCOLOR(218,165,32), @"goldenrod",\
					RGBCOLOR(128,128,128), @"gray",\
					RGBCOLOR(0,128,0), @"green",\
					RGBCOLOR(173,255,47), @"greenyellow",\
					RGBCOLOR(128,128,128), @"grey",\
					RGBCOLOR(240,255,240), @"honeydew",\
					RGBCOLOR(255,105,180), @"hotpink",\
					RGBCOLOR(205,92,92), @"indianred",\
					RGBCOLOR(75,0,130), @"indigo",\
					RGBCOLOR(255,255,240), @"ivory",\
					RGBCOLOR(240,230,140), @"khaki",\
					RGBCOLOR(230,230,250), @"lavender",\
					RGBCOLOR(255,240,245), @"lavenderblush",\
					RGBCOLOR(124,252,0), @"lawngreen",\
					RGBCOLOR(255,250,205), @"lemonchiffon",\
					RGBCOLOR(173,216,230), @"lightblue",\
					RGBCOLOR(240,128,128), @"lightcoral",\
					RGBCOLOR(224,255,255), @"lightcyan",\
					RGBCOLOR(250,250,210), @"lightgoldenrodyellow",\
					RGBCOLOR(211,211,211), @"lightgray",\
					RGBCOLOR(144,238,144), @"lightgreen",\
					RGBCOLOR(211,211,211), @"lightgrey",\
					RGBCOLOR(255,182,193), @"lightpink",\
					RGBCOLOR(255,160,122), @"lightsalmon",\
					RGBCOLOR(32,178,170), @"lightseagreen",\
					RGBCOLOR(135,206,250), @"lightskyblue",\
					RGBCOLOR(119,136,153), @"lightslategray",\
					RGBCOLOR(119,136,153), @"lightslategrey",\
					RGBCOLOR(176,196,222), @"lightsteelblue",\
					RGBCOLOR(255,255,224), @"lightyellow",\
					RGBCOLOR(0,255,0), @"lime",\
					RGBCOLOR(50,205,50), @"limegreen",\
					RGBCOLOR(250,240,230), @"linen",\
					RGBCOLOR(255,0,255), @"magenta",\
					RGBCOLOR(128,0,0), @"maroon",\
					RGBCOLOR(102,205,170), @"mediumaquamarine",\
					RGBCOLOR(0,0,205), @"mediumblue",\
					RGBCOLOR(186,85,211), @"mediumorchid",\
					RGBCOLOR(147,112,219), @"mediumpurple",\
					RGBCOLOR(60,179,113), @"mediumseagreen",\
					RGBCOLOR(123,104,238), @"mediumslateblue",\
					RGBCOLOR(0,250,154), @"mediumspringgreen",\
					RGBCOLOR(72,209,204), @"mediumturquoise",\
					RGBCOLOR(199,21,133), @"mediumvioletred",\
					RGBCOLOR(25,25,112), @"midnightblue",\
					RGBCOLOR(245,255,250), @"mintcream",\
					RGBCOLOR(255,228,225), @"mistyrose",\
					RGBCOLOR(255,228,181), @"moccasin",\
					RGBCOLOR(255,222,173), @"navajowhite",\
					RGBCOLOR(0,0,128), @"navy",\
					RGBCOLOR(253,245,230), @"oldlace",\
					RGBCOLOR(128,128,0), @"olive",\
					RGBCOLOR(107,142,35), @"olivedrab",\
					RGBCOLOR(255,165,0), @"orange",\
					RGBCOLOR(255,69,0), @"orangered",\
					RGBCOLOR(218,112,214), @"orchid",\
					RGBCOLOR(238,232,170), @"palegoldenrod",\
					RGBCOLOR(152,251,152), @"palegreen",\
					RGBCOLOR(175,238,238), @"paleturquoise",\
					RGBCOLOR(219,112,147), @"palevioletred",\
					RGBCOLOR(255,239,213), @"papayawhip",\
					RGBCOLOR(255,218,185), @"peachpuff",\
					RGBCOLOR(205,133,63), @"peru",\
					RGBCOLOR(255,192,203), @"pink",\
					RGBCOLOR(221,160,221), @"plum",\
					RGBCOLOR(176,224,230), @"powderblue",\
					RGBCOLOR(128,0,128), @"purple",\
					RGBCOLOR(255,0,0), @"red",\
					RGBCOLOR(188,143,143), @"rosybrown",\
					RGBCOLOR(65,105,225), @"royalblue",\
					RGBCOLOR(139,69,19), @"saddlebrown",\
					RGBCOLOR(250,128,114), @"salmon",\
					RGBCOLOR(244,164,96), @"sandybrown",\
					RGBCOLOR(46,139,87), @"seagreen",\
					RGBCOLOR(255,245,238), @"seashell",\
					RGBCOLOR(160,82,45), @"sienna",\
					RGBCOLOR(192,192,192), @"silver",\
					RGBCOLOR(135,206,235), @"skyblue",\
					RGBCOLOR(106,90,205), @"slateblue",\
					RGBCOLOR(112,128,144), @"slategray",\
					RGBCOLOR(112,128,144), @"slategrey",\
					RGBCOLOR(255,250,250), @"snow",\
					RGBCOLOR(0,255,127), @"springgreen",\
					RGBCOLOR(70,130,180), @"steelblue",\
					RGBCOLOR(210,180,140), @"tan",\
					RGBCOLOR(0,128,128), @"teal",\
					RGBCOLOR(216,191,216), @"thistle",\
					RGBCOLOR(255,99,71), @"tomato",\
					RGBCOLOR(64,224,208), @"turquoise",\
					RGBCOLOR(238,130,238), @"violet",\
					RGBCOLOR(245,222,179), @"wheat",\
					RGBCOLOR(245,245,245), @"whitesmoke",\
					RGBCOLOR(255,255,0), @"yellow",\
					RGBCOLOR(154,205,50), @"yellowgreen",\
					RGBACOLOR(0xFF, 0xFF, 0xFF, 0x00), @"transparent",\
					[UIColor whiteColor], @"white",\
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

	// Validate CSS Color. Anything more or less is unsupported, and therefore this
	// property is ignored according to the W3C guidelines.
	BOOL validCss =	   [cssValues count] == 1
					|| [cssValues count] == 5    // rgb( x x x )
					|| [cssValues count] == 6;   // rgba( x x x x )
	if ( !validCss )
		[NSException raise:@"TTCSSColorFormatter" format:@"Invalid CSS color values: '%@'", cssValues];

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
			UIColor *color = [__colorLookupTable objectForKey:cssString];
			// If not found, raise error.
			if ( !color )
				[NSException raise:@"TTCSSColorFormatter"
							format:@"'%@' isn't a valid W3C CSS Extended color keywords.", cssString];
			// Return correct.
			return color;
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


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Sizes.
///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Helper function to convert an CSS readed size to CGFloat.
 */
CGFloat TTValueFromCssValues( NSString* value ) {
    // Pixel measure.
    if ( ! NSEqualRanges( [value rangeOfString:@"px"], (NSRange){NSNotFound,0} )) {
        value = [value stringByReplacingOccurrencesOfString:@"px" withString:@""];
        return [[TTDataConverter convertToNSNumberThisObject:value] floatValue];
    }
    return 0;
}

