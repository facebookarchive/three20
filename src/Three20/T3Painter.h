/*
 * Copyright 2008 Facebook
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

#import "Three20/T3Global.h"

typedef enum {
  T3BackgroundNone,
  T3BackgroundGrayBar,
  T3BackgroundInnerShadow,
  T3BackgroundRoundedRect,
  T3BackgroundPointedRect,
  T3BackgroundRoundedMask,
  T3BackgroundStrokeTop,
  T3BackgroundStrokeRight,
  T3BackgroundStrokeBottom,
  T3BackgroundStrokeLeft
} T3Background;

@interface T3Painter : NSObject

+ (void)drawGrayBar:(CGRect)rect bottom:(BOOL)bottom;

+ (void)drawInnerShadow:(CGRect)rect;

+ (void)drawRoundedRect:(CGRect)rect fill:(const CGFloat*)fillColors fillCount:(int)fillCount
    stroke:(const CGFloat*)strokeColor radius:(CGFloat)radius;
    
+ (void)drawPointedRect:(CGRect)rect fill:(const CGFloat*)fillColors fillCount:(int)fillCount
    stroke:(const CGFloat*)strokeColor radius:(CGFloat)radius;

+ (void)drawRoundedMask:(CGRect)rect fill:(const CGFloat*)fillColors
    stroke:(const CGFloat*)strokeColor radius:(CGFloat)radius;

+ (void)strokeLines:(CGRect)rect background:(T3Background)background
  stroke:(const CGFloat*)strokeColor;

+ (void)drawLine:(CGPoint)from to:(CGPoint)to color:(UIColor*)color;

+ (void)drawBackground:(T3Background)background rect:(CGRect)rect fill:(UIColor*)fillColor
  fillCount:(int)fillCount stroke:(UIColor*)strokeColor radius:(CGFloat)radius;

+ (void)drawBackground:(T3Background)background rect:(CGRect)rect;

@end
