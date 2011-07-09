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

#import "extThree20CSSStyle/UIView+CSSAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(TTCSSViewAdditions)

@implementation UIView (TTCSSAdditions)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Receive an Set of Rules from some CSS selector to apply. This method
// receive an TTCSSRuleSet with all properties ready to be set.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyCssRules:(TTCSSRuleSet*)anRuleSet {
	// Set properties from CSS.
	self.backgroundColor = anRuleSet.background_color;

    // Hidden?
    self.hidden = anRuleSet.hidden;

    // Original frame.
    CGRect newFrame = self.frame;

    // Change Frame from CSS values if needed.
    newFrame.origin.x    = ( anRuleSet.left ? anRuleSet.origin.x : newFrame.origin.x );
    newFrame.origin.y    = ( anRuleSet.top ? anRuleSet.origin.y : newFrame.origin.y );
    ///
    newFrame.size.width  = ( anRuleSet.width ? anRuleSet.size.width : newFrame.size.width );
    newFrame.size.height = ( anRuleSet.height ? anRuleSet.size.height : newFrame.size.height );

    // Apply.
    self.frame = newFrame;
}

@end
