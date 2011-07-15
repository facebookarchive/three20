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

#import "Three20Style/TTTextStyle.h"

@interface TTTextStyle (TTCSSCategory)

+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                                next:(TTStyle*)next;

+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                     minimumFontSize:(CGFloat)minimumFontSize
                                next:(TTStyle*)next;

+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                     minimumFontSize:(CGFloat)minimumFontSize
                       textAlignment:(UITextAlignment)textAlignment
                   verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
                       lineBreakMode:(UILineBreakMode)lineBreakMode
                       numberOfLines:(NSInteger)numberOfLines
                                next:(TTStyle*)next;


+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                            forState:(UIControlState)state
                                next:(TTStyle*)next;

+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                            forState:(UIControlState)state
                     minimumFontSize:(CGFloat)minimumFontSize
                                next:(TTStyle*)next;

+ (TTTextStyle*)styleWithCssSelector:(NSString*)selector
                            forState:(UIControlState)state
                     minimumFontSize:(CGFloat)minimumFontSize
                       textAlignment:(UITextAlignment)textAlignment
                   verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
                       lineBreakMode:(UILineBreakMode)lineBreakMode
                       numberOfLines:(NSInteger)numberOfLines
                                next:(TTStyle*)next;

@end
