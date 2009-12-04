/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (TTCategory)

+ (UIColor*)colorWithHue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v alpha:(CGFloat)a;

- (UIColor*)multiplyHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

- (UIColor*)addHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

- (UIColor*)copyWithAlpha:(CGFloat)newAlpha;

/**
 * Uses multiplyHue to create a lighter version of the color.
 */
- (UIColor*)highlight;

/**
 * Uses multiplyHue to create a darker version of the color.
 */
- (UIColor*)shadow;

- (CGFloat)hue;

- (CGFloat)saturation;

- (CGFloat)value;

@end
