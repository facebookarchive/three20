/*
 * Copyright (c) 2011 - SEQOY.org and Paulo Oliveira ( http://www.seqoy.org )
 * JUMP GIT Repository: https://github.com/seqoy/jump
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import "extThree20CSSStyle/TTDataConverter.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTDataConverter

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Convert Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
// Take an NSString Object and try to convert to NSNumber.
///////////////////////////////////////////////////////////////////////////////////////////////////
+(NSNumber*)convertToNSNumberThisObject:(id)anObject {

	// Convert from NSString to NSNumber.
	if ( [anObject isKindOfClass:[NSString class]] ) {

		// Create an Scanner, the scaner will scan the string looking for specific type number.
		NSScanner *stringScanner = [NSScanner scannerWithString:anObject];

		// NOTE: The order is very important ->-- 'float' after 'double' and then 'int'.

		// Scan string looking for FLOAT.
		float aFloat;
		if ( [stringScanner scanFloat:&aFloat] )
			return [NSNumber numberWithFloat:[anObject floatValue]];

		// Scan string looking for DOUBLE.
		double aDouble;
		if ( [stringScanner scanDouble:&aDouble] )
			return [NSNumber numberWithDouble:[anObject doubleValue]];

		// Scan string looking for INT.
		int aInt;
		if ( [stringScanner scanInt:&aInt] )
			return [NSNumber numberWithInt:[anObject intValue]];
	}

	// Can't convert, return NIL.
	return nil;
}
@end
