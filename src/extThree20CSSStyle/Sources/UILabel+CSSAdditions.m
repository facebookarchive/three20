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
#import "extThree20CSSStyle/UILabel+CSSAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

#ifdef __IPHONE_3_2
#import <QuartzCore/QuartzCore.h>
#endif

/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(TTCSSLabelAdditions)

@implementation UILabel (TTCSSAdditions)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Receive an Set of Rules from some CSS selector to apply. This method
// receive an TTCSSRuleSet with all properties ready to be set.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyCssRules:(TTCSSRuleSet*)anRuleSet {
	// Super.
	[super applyCssRules:anRuleSet];

	// Set properties from CSS, if defined.
	if (anRuleSet.font)  self.font      = anRuleSet.font;
	if (anRuleSet.color) self.textColor = anRuleSet.color;

	// Alignment.
	if (anRuleSet.text_align) self.textAlignment = [anRuleSet textAlign];

	// Set Shadow, if needed.
	if (anRuleSet.text_shadow.shadowColor) {

		// iPhone 3.2 accept blur on shadows, so do it.
		#ifdef __IPHONE_3_2
			// If blur defined.
			if (anRuleSet.text_shadow.shadowBlur) {
				self.layer.shadowOpacity = [anRuleSet.text_shadow_opacity floatValue];
				self.layer.shadowColor   = [anRuleSet.text_shadow.shadowColor CGColor];
				self.layer.shadowOffset  = anRuleSet.text_shadow.shadowOffset;
				self.layer.shadowRadius  = [anRuleSet.text_shadow.shadowBlur floatValue];
				self.layer.masksToBounds = NO;
			}
			//////////// ///// ///// ///// ///// ///// ///// ///// /////
			// If not.
			else {
				self.shadowColor  = anRuleSet.text_shadow.shadowColor;
				self.shadowOffset = anRuleSet.text_shadow.shadowOffset;
			}
			//////////// ///// ///// ///// ///// ///// ///// ///// /////
			// If not, just color and offset.
		#else
			self.shadowColor  = anRuleSet.text_shadow.shadowColor;
			self.shadowOffset = anRuleSet.text_shadow.shadowOffset;
		#endif
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Receive an Set of Rules from some CSS selector to apply. This method
// receive an TTCSSRuleSet with all properties ready to be set.
///////////////////////////////////////////////////////////////////////////////////////////////////


@end


