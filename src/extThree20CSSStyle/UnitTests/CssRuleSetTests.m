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
// See Also: http://bit.ly/hgpqd2

#import <SenTestingKit/SenTestingKit.h>

#import "TTCSSRuleSet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

@interface CssRuleSetTests : SenTestCase {
	TTCSSRuleSet *_ruleSet;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CssRuleSetTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
	_ruleSet = [[TTCSSRuleSet initWithSelectorName:@"testSelector"] retain];
	STAssertNotNil( _ruleSet, @"CSS Rule Set Object wasn't initiated correctly");
	STAssertTrue( [_ruleSet.selector isEqualToString:@"testSelector"],
				 @"Selector name wasn't setted correctly." );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
    TT_RELEASE_SAFELY(_ruleSet);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)testLoadColorData {
//	// Test UI Color.
//	UIColor *anColor		  = [UIColor redColor];
//	_ruleSet.color			  = anColor;
//	_ruleSet.background_color = anColor;
//	/////////////////////// //////////////// /////////////////////// ////////////////
//	STAssertTrue( anColor == _ruleSet.color,
//				 @"'color' property with UIColor value wasn't setted correctly" );
//	/////////////////////// //////////////// /////////////////////// ////////////////
//	STAssertTrue( anColor == _ruleSet.background_color,
//				 @"'background_color' property with UIColor value wasn't setted correctly" );
//
//	/////////////////////// //////////////// /////////////////////// ////////////////
//	// Test String Color.
//	_ruleSet.color			  = @"red";
//	_ruleSet.background_color = @"red";
//	/////////////////////// //////////////// /////////////////////// ////////////////
//	STAssertTrue( anColor == _ruleSet.color,
//				 @"'color' property with String value wasn't setted correctly" );
//	/////////////////////// //////////////// /////////////////////// ////////////////
//	STAssertTrue( anColor == _ruleSet.background_color,
//				 @"'background_color' property with String value wasn't setted correctly" );
//}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testFont {
	// Set font values.
	_ruleSet.font_family	= @"Helvetica";
	_ruleSet.font_weight	= @"BoldOblique";
	_ruleSet.font_size		= [NSNumber numberWithInt:10];
	/////////////////////// //////////////// /////////////////////// ////////////////
	STAssertTrue( [_ruleSet.font_family isEqualToString:@"Helvetica"],
				 @"'font_family' property wasn't setted correctly" );
	/////////////////////// ////////////////	/////////////////////// ////////////////
	STAssertTrue( [_ruleSet.font_weight isEqualToString:@"BoldOblique"],
				 @"'font_weight' property wasn't setted correctly" );
	/////////////////////// //////////////// /////////////////////// ////////////////
	STAssertTrue( [_ruleSet.font_size intValue] == 10,
				 @"'font_size' property wasn't setted correctly" );
	/////////////////////// //////////////// /////////////////////// ////////////////
 	//UIFont *createdFont = _ruleSet.font;
	//STAssertNotNil( createdFont, @"Font must be created at this time");
}


@end
