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

#import "extThree20CSSStyle/UILabelAdditions.h"

#import "extThree20CSSStyle/TTCSSGlobalStyle.h"
#import "extThree20CSSStyle/TTCSSStyleSheet.h"
#import "extThree20CSSStyle/TTDefaultCSSStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

#ifdef __IPHONE_3_2
#import <QuartzCore/QuartzCore.h>
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(TTCSSLabelAdditions)

@implementation UILabel (TTCSSCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyCssSelector:(NSString *)selector {
  UIFont  *font            = TTCSS(selector, font);
  UIColor *color           = TTCSS(selector, color);
  UIColor *backgroundColor = TTCSS(selector, backgroundColor);

  if (font)            self.font            = font;
  if (color)           self.textColor       = color;
  if (backgroundColor) self.backgroundColor = backgroundColor;

  UIColor *shadowColor     = TTCSS(selector, shadowColor);
  CGSize   shadowOffset    = TTCSS(selector, shadowOffset);
  if (shadowColor) {
#ifdef __IPHONE_3_2
    CGFloat shadowRadius = TTCSS(selector, shadowRadius);
    if (shadowRadius) {
      self.layer.shadowOpacity = 1.0;
      self.layer.shadowColor   = shadowColor.CGColor;
      self.layer.shadowOffset  = shadowOffset;
      self.layer.shadowRadius  = shadowRadius;
      self.layer.masksToBounds = NO;
    }
    else {
      self.shadowColor  = shadowColor;
      self.shadowOffset = shadowOffset;
    }
#else
    self.shadowColor  = shadowColor;
    self.shadowOffset = shadowOffset;
#endif
  }
}

@end
