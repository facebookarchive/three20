//
//  MinRadialGradientStyle.h
//  eReader
//
//  Created by Kemal Enver on 23/08/2011.
//  Copyright (c) 2011 Mineus. All rights reserved.
//

#import "Three20Style/TTStyle.h"

@interface TTRadialGradientStyle : TTStyle { 
	
	UIColor* _color1; 
	UIColor* _color2; 
} 

@property(nonatomic,retain) UIColor *color1; 
@property(nonatomic,retain) UIColor *color2; 

+ (TTRadialGradientStyle*) styleWithColor1: (UIColor *) color1 color2: (UIColor *) color2 next: (TTStyle *) next; 

@end 
