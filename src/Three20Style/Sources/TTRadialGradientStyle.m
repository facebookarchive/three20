//
//  MINRadialGradientStyle.m
//  eReader
//
//  Created by Kemal Enver on 23/08/2011.
//  Copyright (c) 2011 Mineus. All rights reserved.
//

#import "Three20Style/TTRadialGradientStyle.h"

// Style
#import "Three20Style/TTShape.h"
#import "Three20Style/TTStyleContext.h"

// Style (private)
#import "Three20Style/private/TTStyleInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@implementation TTRadialGradientStyle

@synthesize color1 = _color1;
@synthesize color2 = _color2;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc { 
	
	TT_RELEASE_SAFELY(_color1); 
	TT_RELEASE_SAFELY(_color2); 
	
	[super dealloc]; 
} 

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public

+ (TTRadialGradientStyle*) styleWithColor1:(UIColor*)color1 color2: (UIColor*)color2 next:(TTStyle*)next { 
	
	TTRadialGradientStyle* style = [[[self alloc] initWithNext:next] autorelease]; 
	style.color1 = color1; 
	style.color2 = color2; 
	
	return style; 
} 

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle

- (void)draw:(TTStyleContext*)context { 
	
	CGContextRef ctx = UIGraphicsGetCurrentContext(); 
	CGRect rect = context.frame; 
	
	CGContextSaveGState(ctx); 
	[context.shape addToPath:rect]; 
	CGContextClip(ctx); 
	
	UIColor* colors[] = {_color1, _color2}; 
	CGGradientRef gradient = [self newGradientWithColors: colors count:2]; 
	
	CGPoint centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)); 
	CGFloat width = fabs(CGRectGetMaxX(rect) - centerPoint.x); 
	CGFloat height = fabs(CGRectGetMaxY(rect) - centerPoint.y); 
	
	CGContextDrawRadialGradient(ctx, gradient, centerPoint, 0, centerPoint, fmin(width, height), kCGGradientDrawsAfterEndLocation); 
	
	CGGradientRelease(gradient); 
	
	CGContextRestoreGState(ctx); 
	
	return [self.next draw: context]; 
} 

@end
