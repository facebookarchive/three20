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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "Three20Style/UIColorAdditions.h"

@interface UIAdditionTests : SenTestCase {
}

@end


@implementation UIAdditionTests

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIColor Additions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)color:(UIColor*)color1 equalsColor:(UIColor*)color2 {
  const CGFloat* rgba1 = CGColorGetComponents(color1.CGColor);
  const CGFloat* rgba2 = CGColorGetComponents(color2.CGColor);
  return 0 == memcmp(rgba1, rgba2, sizeof(CGFloat) * 4);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testUIColor {
  for (CGFloat hue = 0; hue < 360; ++hue) {
    UIColor* color = [UIColor colorWithHue:hue saturation:0 value:1 alpha:1];
    STAssertTrue(
      [self color:color equalsColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]],
      @"HSV %f, 0, 1 should be white", hue);
  }

  for (CGFloat hue = 0; hue < 360; ++hue) {
    UIColor* color = [UIColor colorWithHue:hue saturation:0 value:0 alpha:1];
    STAssertTrue(
      [self color:color equalsColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]],
      @"HSV %f, 0, 0 should be black", hue);
  }

  UIColor* color = [UIColor colorWithHue:0 saturation:1 value:1 alpha:1];
  STAssertTrue(
    [self color:color equalsColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]],
    @"HSV 0, 1, 1 should be red");

  color = [UIColor colorWithHue:180 saturation:1 value:1 alpha:1];
  STAssertTrue(
    [self color:color equalsColor:[UIColor colorWithRed:0 green:1 blue:1 alpha:1]],
    @"HSV 180, 1, 1 should be teal");

  color = [UIColor colorWithHue:90 saturation:1 value:1 alpha:1];
  STAssertTrue(
    [self color:color equalsColor:[UIColor colorWithRed:0.5 green:1 blue:0 alpha:1]],
    @"HSV 90, 1, 1 should be yellow");

  color = [UIColor colorWithHue:270 saturation:1 value:1 alpha:1];
  STAssertTrue(
    [self color:color equalsColor:[UIColor colorWithRed:0.5 green:0 blue:1 alpha:1]],
    @"HSV 270, 1, 1 should be magenta");

  color = [UIColor colorWithHue:0 saturation:0.5 value:1 alpha:1];
  STAssertTrue(
    [self color:color equalsColor:[UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1]],
    @"HSV 0, 0.5, 1 should be light red");
}


@end
