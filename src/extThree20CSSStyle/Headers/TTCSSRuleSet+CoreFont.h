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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
#import <CoreText/CoreText.h>
#endif

/**
 * TTCSSRuleSet(CoreText) add Core Text support top the TTCSSRuleSet class,
 * new helper methods sum very nice functionalities for those using
 * <tt>NSAttributedString</tt> with CSS.
 * <br>
 * <b>Core Text is available from iOS 3.2 or later.</b> You can't
 * use this features on systems under 3.2. However this files will
 * be included on your bundle, to ensure maximum compatiblity
 * add the Core Text Framework to your project as set the link as <b>weak</b>.
 */
@interface TTCSSRuleSet(CoreText)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
/**
 * Return an formatted <b>Core Text Font</b> (<tt>CTFontRef</tt>)
 * based on the defined properties.
 * Will return <tt>NULL</tt> if can't format.
 */
-(CTFontRef)coreTextFont;

/**
 * Return an formatted <tt>CTTextAlignment</tt> based on the defined <tt>'text_align'</tt> property.
 * If isn't setted return natural alignment (<tt>kCTNaturalTextAlignment</tt>).
 */
-(CTTextAlignment)paragraphAlign;

/**
 * Return an formatted <tt>CTUnderlineStyle</tt> based on
 * the defined <tt>'text_decoration'</tt> property.
 * If isn't setted return <tt>kCTUnderlineStyleNone</tt>.
 */
-(CTUnderlineStyle)underlineStyle;

/**
 * Return a Dictionary with formatted <tt>NSAttributedString</tt> dictionary based
 * on the CSS defined in this object. See <b>Core Text String Attribute Name Constants</b>
 * to consult the Keys of this dictionary.
 */
-(NSDictionary*)attributedStringDictionary;
#endif

@end
