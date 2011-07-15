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

#import "extThree20CSSStyle/TTTextStyleAdditions.h"

#import "extThree20CSSStyle/TTCSSGlobalStyle.h"
#import "extThree20CSSStyle/TTCSSStyleSheet.h"
#import "extThree20CSSStyle/TTDefaultCSSStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(TTCSSTextStyleAdditions)

@implementation TTTextStyle (TTCSSCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                            forState:(UIControlState)state
                                next:(TTStyle*)next {
  TTTextStyle* style = [[[self alloc] initWithNext:next] autorelease];
  UIFont  *font         = TTCSSSTATE(selector, font, state);
  UIColor *color        = TTCSSSTATE(selector, color, state);
  UIColor *shadowColor  = TTCSSSTATE(selector, shadowColor, state);
  CGSize   shadowOffset = TTCSSSTATE(selector, shadowOffset, state);

  if (font)  style.font  = font;
  if (color) style.color = color;
  if (shadowColor) {
    style.shadowColor  = shadowColor;
    style.shadowOffset = shadowOffset;
  }
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                            forState:(UIControlState)state
                     minimumFontSize:(CGFloat)minimumFontSize
                                next:(TTStyle*)next {
  TTTextStyle* style = [self styleWithCssSelector:selector forState:state next:next];
  style.minimumFontSize = minimumFontSize;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                            forState:(UIControlState)state
                     minimumFontSize:(CGFloat)minimumFontSize
                       textAlignment:(UITextAlignment)textAlignment
                   verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
                       lineBreakMode:(UILineBreakMode)lineBreakMode
                       numberOfLines:(NSInteger)numberOfLines
                                next:(TTStyle*)next {
  TTTextStyle* style = [self styleWithCssSelector:selector forState:state next:next];
  style.minimumFontSize = minimumFontSize;
  style.textAlignment = textAlignment;
  style.verticalAlignment = verticalAlignment;
  style.lineBreakMode = lineBreakMode;
  style.numberOfLines = numberOfLines;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector next:(TTStyle*)next {
  return [self styleWithCssSelector:selector
                           forState:UIControlStateNormal
                               next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                     minimumFontSize:(CGFloat)minimumFontSize
                                next:(TTStyle*)next {
  return [self styleWithCssSelector:selector
                           forState:UIControlStateNormal
                    minimumFontSize:minimumFontSize
                               next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                     minimumFontSize:(CGFloat)minimumFontSize
                       textAlignment:(UITextAlignment)textAlignment
                   verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
                       lineBreakMode:(UILineBreakMode)lineBreakMode
                       numberOfLines:(NSInteger)numberOfLines
                                next:(TTStyle*)next {
  return [self styleWithCssSelector:selector
                           forState:UIControlStateNormal
                    minimumFontSize:minimumFontSize
                      textAlignment:textAlignment
                  verticalAlignment:verticalAlignment
                      lineBreakMode:lineBreakMode
                      numberOfLines:numberOfLines
                               next:next];
}

@end
