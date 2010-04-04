//
//  StyleSheet.m
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright 2010 Brush The Dog, Inc. All rights reserved.
//

#import "StyleSheet.h"


@implementation StyleSheet

- (UIFont*)font {
	return [UIFont fontWithName:@"Georgia" size:11];
}

- (UIFont*)tableFont {
	return [UIFont fontWithName:@"Georgia" size:12];
}


- (UIFont*)tableHeaderPlainFont {
	return [UIFont fontWithName:@"Georgia" size:13];
}

-(UIFont*)titleFont {
	return [UIFont fontWithName:@"Georgia-Bold" size:14];
}

- (UIColor *)tableGroupedBackgroundColor
{
  return RGBCOLOR(224,221, 203);
}

- (UIColor*)tableHeaderTextColor
{
  return [UIColor brownColor];
}

- (UIColor*)tableHeaderTintColor {
  return RGBCOLOR(224,221, 203);
}

- (UIColor*)navigationBarTintColor {
  return RGBCOLOR(181,128, 108);
}

@end
