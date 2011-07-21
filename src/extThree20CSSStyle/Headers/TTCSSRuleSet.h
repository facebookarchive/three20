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
	NSNumber* text_shadow_opacity;

	// Background properties.
	NSString *background_image;

    // Visibility.
    NSString *visibility;

    // Positioning and size.
    NSString *width;
    NSString *height;
    NSString *top;
    NSString *left;
    NSString *right;
    NSString *bottom;

    // Object alignment.
    NSString *vertical_align;

    // Margins.
    NSString *margin_right;
    NSString *margin_left;
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
 *		- <tt>left</tt>: Align text along the left edge.<br>
 *		- <tt>center</tt>: Align text equally along both sides of the center line.<br>
 *		- <tt>right</tt>: Align text along the right edge.<br>
 * <br>
 * Use the textAlign method to retrieve an iOS formatted UITextAlignment
 * based on this values.
 */
@property (copy) NSString* text_align;

/**
 * This property specifies the size of an element’s rendering box.
 * Possible Values:<br>
 *      - <tt>auto</tt>: The width is determinant on the values of other properties.
 *      - <tt>length</tt>: Refers to an absolute measurement for the computed
 * element box width. Negative values are not allowed.
 *      - <tt>percentage</tt>: Refers to a percentage of the width of the containing
 * element block.<br>
 * Examples:<br>
 *    <tt>"75px", "50%"</tt>
 */
@property (copy) NSString* width;

/**
 * /copydef width
 */
@property (copy) NSString* height;

@property (copy) NSString* top;
@property (copy) NSString* left;
@property (copy) NSString* right;
@property (copy) NSString* bottom;

/**
 * The visibility property specifies whether or not an element is visible.
 * Possible Values:<br>
 *      - <tt>visible</tt>: The element is visible. <b>This is default.</b>
 *      - <tt>hidden</tt>: The element is invisible.
 */
@property (copy) NSString* visibility;

/**
 * An TTCSSTextShadowModel object that define a text shadow properties.
 */
@property (retain) TTCSSTextShadowModel* text_shadow;

/**
 * Specifies the opacity of the receiver’s text shadow.
 * The default value is 0.
 */
@property (copy) NSNumber* text_shadow_opacity;

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

/**
 * This property sets the vertical alignment of an element.
 * Values have the following meanings:<br>
 *		- <tt>top</tt>: The top of the element is aligned with the top of the
 * tallest element on the line.<br>
 *		- <tt>middle</tt>: The element is placed in the middle of the parent element.<br>
 *		- <tt>bottom</tt>: The bottom of the element is aligned with the lowest element on the line.<br>
 * <br>
 * Use the contentVerticalAlignment method to retrieve an iOS formatted
 * UIControlContentVerticalAlignment based on this values.
 */
@property (copy) NSString* vertical_align;

/**
 * This property specifies the left margin of an element.
 * Possible Values:<br>
 *      - <tt>auto</tt>: The left margin is calculated automatically.
 *      - <tt>length</tt>: Specifies a fixed left margin in px.
 *      - <tt>percentage</tt>: Specifies a left margin in percent.
 * Examples:<br>
 *    <tt>"75px", "50%"</tt>
 */
@property (copy) NSString* margin_left;

/**
 * This property specifies the right margin of an element.
 * Possible Values:<br>
 *      - <tt>auto</tt>: The right margin is calculated automatically.
 *      - <tt>length</tt>: Specifies a fixed right margin in px.
 *      - <tt>percentage</tt>: Specifies a left margin in percent.
 * Examples:<br>
 *    <tt>"75px", "50%"</tt>
 */
@property (copy) NSString* margin_right;

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
 * If isn't setted return default left alignment.
 */
-(UITextAlignment)textAlign;

/**
 * Return an formatted CGSize based on the defined <tt>'width'</tt>
 * and <tt>'height'</tt> properties.
 */
-(CGSize)size;

/**
 * Return an formatted CGPoint based on the defined <tt>'top'</tt>
 * and <tt>'left'</tt> properties.
 */
-(CGPoint)origin;

/**
 * Return an Boolean value that determines whether the receiver is hidden based
 * on the <tt>'visibility'</tt> property.
 */
-(BOOL)hidden;

/**
 * Return an formatted UIControlContentVerticalAlignment based on the defined
 * <tt>'vertical_align'</tt> property. If isn't setted return default top alignment.
 */
-(UIControlContentVerticalAlignment)contentVerticalAlignment;

/**
 * Return an formatted UIControlContentHorizontalAlignment based on the defined
 * <tt>'margin-left'</tt> and <tt>margin-right</tt> properties.
 * If isn't setted return default left alignment.
 */
-(UIControlContentHorizontalAlignment)contentHorizontalAlignment;
@end
