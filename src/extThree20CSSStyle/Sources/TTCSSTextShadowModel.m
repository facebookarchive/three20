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

#import "extThree20CSSStyle/TTCSSTextShadowModel.h"
#import "extThree20CSSStyle/TTCSSFunctions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"

@implementation TTCSSTextShadowModel
@synthesize shadowOffset, shadowColor, shadowBlur;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init Methods.

///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)initWithShadowColor:(id)anColor andShadowOffset:(CGSize)anOffset {
	TTCSSTextShadowModel *instance = [[TTCSSTextShadowModel new] autorelease];
	instance.shadowColor		   = anColor;
	instance.shadowOffset		   = anOffset;
	return instance;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)initWithShadowColor:(id)anColor andShadowOffset:(CGSize)anOffset
		   andShadowBlur:(NSNumber*)blur {
	TTCSSTextShadowModel *instance = [TTCSSTextShadowModel initWithShadowColor:anColor
															   andShadowOffset:anOffset];
	instance.shadowBlur  = blur;
	return instance;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
	self = [super init];
	if (self != nil) {

		// Default values.
		self.shadowOffset   = CGSizeMake(0, -1);
		self.shadowColor	= [UIColor clearColor];
		self.shadowBlur		= [[NSNumber numberWithInt:3] retain];

	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
	TT_RELEASE_SAFELY( shadowColor );
	TT_RELEASE_SAFELY( shadowBlur );
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Set Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setShadowColor:(id)anValue {

	/////////////////////////////////
	// Release.
	if ( shadowColor )
		TT_RELEASE_SAFELY( shadowColor );

	///////////////////////////////////////
    // Array of color?
	if ( [anValue isKindOfClass:[NSArray class]] ) {

		// Set.
        shadowColor = [TTColorFromCssValues(anValue) retain];

	}

    ///////////////////////////////////////
    // String color?
    else if ( [anValue isKindOfClass:[NSString class]] ) {

        // Set.
        shadowColor = [TTColorFromCssValues([NSArray arrayWithObject:anValue]) retain];
    }

    ///////////////////////////////////////
    // UIColor?
    else if ( [anValue isKindOfClass:[UIColor class]] ) {

		// Set.
        shadowColor = [anValue retain];
    }
}

@end
