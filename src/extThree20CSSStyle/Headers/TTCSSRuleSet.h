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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TTCSSTextShadowModel.h"

@interface TTCSSRuleSet : NSObject  {
	NSString *selector;

	// Colors.
	UIColor *color;
	UIColor *background_color;

	// Font properties.
	NSString *font_family;
	NSString *font_weight;
	NSNumber *font_size;

	// Alignment and Justification.
	NSString *text_align;

	// Text Shadow.
	TTCSSTextShadowModel* text_shadow;

	// Background properties.
	NSString *background_image;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties.

/**
 * The identifier for this rule set. Also knowed as <tt>selector</tt>
 */
@property (copy) NSString *selector;

/**
 * A font family name only specifies a name given to a set of font faces,
 * it does not specify an individual face.
 * You can call <tt>[UIFont familyNames]</tt> to retrieve a list of
 * available fonts on your system. Font family name is case-sensitive,
 * make sure to inform correctly.
 * See <a href="http://www.w3.org/TR/css3-fonts/#font-family-prop">CSS3 Font Family</a>
 * for more information.<br>
 * Default value is the first <b>Default Font Family</b>.
 */
@property (copy) NSString *font_family;

/**
 * The ‘font-weight’ property specifies weight of glyphs in the font.
 * In iOS each font has different font weight descriptions (such as Medium, Light, Oblique, etc.).
 * You can call <tt>[UIFont familyNames]</tt> to retrieve a list of available fonts on your system.
 * Default value is <tt>nil</tt>.<br>
 * <br>
 * <b>Example:</b><br>
 * To use the font <tt>Helvetica-BoldOblique</tt> you should
 * inform <tt>BoldOblique</tt> as font-weight and <tt>Helvetica</tt> as font_family.
 * <br>
 * Font weight name is case-sensitive, make sure to inform correctly.
 */
@property (copy) NSString *font_weight;

/**
 * This property indicates the desired height of glyphs from the font.
 * This value is always interpreted in points, regardless of what you specify.
 * This is due to the tricky nature of varying DPI on the various iPhone OS devices.
 * Default value is the <b>Default System Font Size</b> (<tt>[UIFont systemFontSize]</tt>).
 */
@property (copy) NSNumber *font_size;

/**
 * This property describes how inline contents of a block are horizontally
 * aligned. Values have the following meanings:<br>
 * - left: Align text along the left edge.<br>
 * - center: Align text equally along both sides of the center line.<br>
 * - right: Align text along the right edge.<br>
 * <br>
 * You should use the textAlign method to retrieve an iOS formatted UITextAlignment.
 */
@property (copy) NSString* text_align;

/**
 * An TTCSSTextShadowModel object that define a text shadow properties.
 */
@property (retain) TTCSSTextShadowModel* text_shadow;

/**
 * This property describes the foreground color of an element.
 * Default value is a transparent color.
 */
@property (retain) id color;

/**
 * This property describes the background color of an element.
 * Default value is a transparent color.
 */
@property (retain) id background_color;

/**
 * This property sets the background image(s) of an element.
 * Default value is <tt>nil</tt>.
 */
@property (copy) NSString *background_image;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init Methods.
+(id)initWithSelectorName:(NSString*)anRuleSetName;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Data Methods.

/**
 * Return an formatted UIFont object based on the defined properties.
 * Will return <tt>nil</tt> if can't format.
 */
-(UIFont*)font;

/**
 * Return an formatted UITextAlignment based on the defined <tt>'text_align'</tt> property.
 */
-(UITextAlignment)textAlign;

@end
