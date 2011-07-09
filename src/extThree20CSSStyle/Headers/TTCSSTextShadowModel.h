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
#import <UIKit/UIKit.h>

@interface TTCSSTextShadowModel : NSObject {

	UIColor* shadowColor;
	NSNumber* shadowBlur;
	CGSize shadowOffset;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties.

/**
 * This is given as a pair of length values indicating x- and y- distances to use as offset.
 * The default offset size is (0, -1), which indicates a shadow one point above the text.
 */
@property (assign) CGSize shadowOffset;

/**
 * The shadowBlur specifies the blur radius used to render the receiver’s shadow.
 * This value coud not be rendered on iOS older than 3.2.
 * The default value is 3.0.
 */
@property (copy) NSNumber* shadowBlur;

/*
 * Define the color to create the shadow effect.
 * The default value for this property is transparent,
 * which indicates that no shadow is drawn.
 */
@property (retain) id shadowColor;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init Methods.
+(id)initWithShadowColor:(id)anColor andShadowOffset:(CGSize)anOffset;
+(id)initWithShadowColor:(id)anColor andShadowOffset:(CGSize)anOffset andShadowBlur:(NSNumber*)blur;

@end
