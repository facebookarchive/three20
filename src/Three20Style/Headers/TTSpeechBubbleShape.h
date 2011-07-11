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

// Style
#import "Three20Style/TTShape.h"

/**
 * The shape that defines a rectangular shape with a pointer.
 *
 */
@interface TTSpeechBubbleShape : TTShape {
  CGFloat _radius;
  CGFloat _pointLocation;
  CGFloat _pointAngle;
  CGSize  _pointSize;
}

@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat pointLocation;
@property (nonatomic) CGFloat pointAngle;
@property (nonatomic) CGSize  pointSize;

/**
 * The shape that defines a rectangular shape with a pointer.
 * Radius - number of pixels for the rounded corners
 * pointLocation - location of the point where the top edge starts at 45, the right edge at 135,
 *                 the bottom edge at 225 and the left edge at 315.
 * pointAngle - not fgunctional yet. Make this equal to pointLocation in order to point it in the
 * right direction.
 * pointSize - the square in which the pointer will be defined, should be narrower or less high than
 *             the shape minus the radiuses.
 *
 * Pointers are not placed on the rounded corners.
 *
 * pointSize should be less wide or high than the edge that it is placed on minus 2 * radius.
 * radius should be smaller than the length of the edge / 2.
 *
 */
+ (TTSpeechBubbleShape*)shapeWithRadius:(CGFloat)radius
                          pointLocation:(CGFloat)pointLocation
                             pointAngle:(CGFloat)pointAngle
                              pointSize:(CGSize)pointSize;

@end
