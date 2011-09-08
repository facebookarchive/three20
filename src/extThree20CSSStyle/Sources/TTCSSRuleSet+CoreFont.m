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

#import "extThree20CSSStyle/TTCSSRuleSet+CoreFont.h"
#import "extThree20CSSStyle/TTCSSFunctions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTCSSRuleSet(CoreText)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
///////////////////////////////////////////////////////////////////////////////////////////////////
// Return an formatted UIFont object based on the defined properties.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIFont*)font {
    // If not enough properties return nil.
    if ( !font_family && !font_size ) {
        TTDWARNING ( @"Can't format UIFont, 'font_family' or 'font_size' isn't defined." );
        return nil;
    }

    // Create a CTFont.
    CTFontRef ctFont = [self coreTextFont];

    //////////////////////////////////
    // If nothing, return nil.
    if ( ctFont == NULL )
        return nil;

    // Grab the Font Name.
    NSString *fontName = (NSString*)CTFontCopyPostScriptName(ctFont);

    //////////////////////////////////
    // Create and return UIFont.
    return [UIFont fontWithName:fontName size:CTFontGetSize(ctFont)];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Return an formatted <b>Core Text Font</b>.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(CTFontRef)coreTextFont {
    // If not enough properties return nil.
    if ( !font_family && !font_size ) {
        TTDWARNING ( @"Can't format CTFontRef, 'font_family' or 'font_size' isn't defined." );
        return NULL;
    }

    ////////// /////////////////// ////////////// //////////////// //////////////// ///////////////
    // Create a CTFont.
    CTFontRef cgFont = CTFontCreateWithName((CFStringRef)[font_family capitalizedString], // Family.
                                            [font_size floatValue],                       // Size.
                                            NULL);

    //////////////////////////////////
    // Font weight.
    BOOL isBold   = [font_weight isEqualToString:@"bold"];

    // Font style.
    BOOL isItalic  = [font_style isEqualToString:@"italic"] ||
                     [font_style isEqualToString:@"oblique"];

    // If isn't bold or italic, just return formatted until now.
    if ( !isBold && !isItalic )
        return cgFont;

    //////// ///////// //////// ///////////// ///////////// /////////
    // Traits init empty and we add as needed:
    CTFontSymbolicTraits symbolicTraits = 0;

    // Bold.
    if (isBold)
        symbolicTraits |= kCTFontBoldTrait;

    // Italic.
    if (isItalic)
        symbolicTraits |= kCTFontItalicTrait;

    // Create a copy of the original font with the masked trait set to the
    // desired value. If the font family does not have the appropriate style,
    // this will return NULL.

    return CTFontCreateCopyWithSymbolicTraits(cgFont,
                                            // 0.0 means the original font’s size is preserved.
                                            0.0,
                                            NULL,
                                            symbolicTraits,
                                            symbolicTraits);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Return a Dictionary with formatted <tt>NSAttributedString</tt> dictionary based
// on the CSS defined in this object.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(CTUnderlineStyle)underlineStyle {
	if ([text_decoration isEqualToString:@"none"]) {
		return kCTUnderlineStyleNone;
	}
	else if ([text_decoration isEqualToString:@"underline"]) {
		return kCTUnderlineStyleSingle;
	}

	return kCTUnderlineStyleNone;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Return an formatted <tt>CTTextAlignment</tt> based on the defined <tt>'text_align'</tt> property.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(CTTextAlignment)paragraphAlign {
	if ([text_align isEqualToString:@"left"]) {
		return kCTLeftTextAlignment;
	}
	else if ([text_align isEqualToString:@"center"]) {
		return kCTCenterTextAlignment;
	}
	else if ([text_align isEqualToString:@"right"]) {
		return kCTRightTextAlignment;
	}
	else if ([text_align isEqualToString:@"justify"]) {
		return kCTJustifiedTextAlignment;
	}

	return kCTNaturalTextAlignment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Return a Dictionary with formatted <tt>NSAttributedString</tt> dictionary based
// on the CSS defined in this object. See <b>NSAttributedString Standard Attributes</b>
// to consult the Keys of this dictionary.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionary*)attributedStringDictionary {

    ////////// /////////////////// ////////////// //////////////// //////////////// ///////////////
    // Create a CTFont.
    CTFontRef cgFont = [self coreTextFont];

    ////////// /////////////////// ////////////// //////////////// //////////////// ///////////////
    // Paragraph settings.
    CFIndex prgphNParams = 1;                            // Total settings to define.

    // Alignment
    CTTextAlignment theAlignment = [self paragraphAlign];
    CTParagraphStyleSetting prgphSettings[1] = {
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment }
    };

    ////////// /////////////////// ///////
    // Create a Paragraph Style.
    CTParagraphStyleRef paragraph = CTParagraphStyleCreate(prgphSettings, prgphNParams);

    ////////// /////////////////// ////////////// //////////////// //////////////// ///////////////
    // Mount attributes.
    NSDictionary *att = [NSDictionary dictionaryWithObjectsAndKeys:

                          // Font name.
                         (id)cgFont, kCTFontAttributeName,

                         // Foreground color.
                         (id)[(UIColor*)[self color] CGColor], kCTForegroundColorAttributeName,

                         // Underline style.
                         [NSNumber numberWithInt:[self underlineStyle]],
                         kCTUnderlineStyleAttributeName,

                         // Paragraph style.
                         paragraph, kCTParagraphStyleAttributeName,

                         nil];
    return att;
}
#endif

@end
