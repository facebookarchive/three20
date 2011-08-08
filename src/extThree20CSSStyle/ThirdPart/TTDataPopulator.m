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
#import "extThree20CSSStyle/TTDataPopulator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTDataPopulator
@synthesize delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)capitalizeFirstLetter:(NSString*)anString {

	NSString *firstLetter = [ [anString substringWithRange:NSMakeRange(0, 1)] uppercaseString];
	NSString *rest		  = [anString substringFromIndex:1];

	// Return formatted String.
	return [NSString stringWithFormat:@"%@%@", firstLetter, rest];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)tryToGrabDataKey:(NSString*)anKey fromMap:(NSDictionary*)anMap {

	// Try To Grab a Data Key
	return [anMap objectForKey:anKey];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(Class)grabTheClassOfProperty:(NSString*)firstKey onObject:(id)firstObject {

	//	///////////// 	///////////// 	///////////// 	///////////// 	/////////////
	/*
	 * To correct compile, you need to ADD the libobjc.A.dylib framework to
	 * your target. And also #import the <objc/runtime.h>
	 */

	// Get the property (Method) attributes.
	objc_property_t property = class_getProperty([firstObject class], [firstKey UTF8String]);

	// Test if some data was returned, first.
	if ( property != NULL ) {

		// Attribute description:
		NSString *attributeDescripion = [NSString stringWithCString:property_getAttributes(property)
														   encoding:[NSString defaultCStringEncoding]];

		// Isolate the Class of this property.
		NSArray *elements = [attributeDescripion componentsSeparatedByString:@"\""];

		// Should have 3 elements, if don't we can't process.
		if ( [elements count] != 3 ) return nil;

		// The second element is what we want... So transform him on a class.
		Class firstKeyClass = NSClassFromString([elements objectAtIndex:1]);

		// And return.
		return firstKeyClass;
	}

	///////////// 	///////////// 	///////
	// If can't decode, return nil.
	return nil;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Check if the *firstKey* (Method) type of the Object **anObject** (Class)
// is the same that the secondKey (Method) secondObject (Class).
///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)checkIfObject:(id)firstObject  ofKey:(NSString*)firstKey
	   hasSameTypeOf:(id)secondObject ofKey:(NSString*)secondKey {

	// Class of the First Key.
	Class firstKeyClass = [self grabTheClassOfProperty:firstKey onObject:firstObject];

	// Return if matches.
	return [secondObject isKindOfClass:firstKeyClass];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Try to convert the **fistObject** to the same type of the **secondObject**.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)tryToConvert:(id)firstObject ofKey:(NSString*)firstKey
 toTheSameClassOf:(id)secondObject ofKey:(NSString*)secondKey {

	// Class of the Second Key.
	Class secondKeyClass = [self grabTheClassOfProperty:secondKey onObject:secondObject];

	// Converted value.
	id converted = nil;

	///////////// 	///////////// 	////////
	// If desired value are an NSNumber.
	if ( secondKeyClass == [NSNumber class] )
		converted = [TTDataConverter convertToNSNumberThisObject:firstObject];

	// Maybe the delegate can convert it...
	if ( delegate )
		if ( [(id)delegate respondsToSelector:@selector(tryToConvert:ofClass:toClass:) ] )
			converted = [delegate tryToConvert:firstObject ofClass:[firstObject class]
									   toClass:secondKeyClass];

	// Return converted.
	return converted;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)populateObject:(id)anObject withData:(NSDictionary*)anDictionary
		   usingMap:(NSDictionary*)anMap {

	//// //// //// //// //// //// //// //// //// //// //// ////
	// Loop every property.
	for ( id property in anDictionary ) {

		// Try to find corresponding data key.
		NSString *dataKey = [self tryToGrabDataKey:property fromMap:anMap];

		// Only process if found.
		if ( dataKey ) {

			// Method Name for corresponding server key.
			NSString *convertedMethodName = [NSString stringWithFormat:@"set%@:",
											 [self capitalizeFirstLetter:dataKey]];

			// Selector for this element.
			SEL anSelector = NSSelectorFromString( convertedMethodName  );

			/////////////////////////////////////////////////////////////////////
			// Check if object responds to this SET selector.
			if ( [anObject respondsToSelector:anSelector]
				&&
				! [[anDictionary objectForKey:property] isKindOfClass:[NSNull class]] )
			{
				// Retrieve the data.
				id serverData = [anDictionary objectForKey:property];

				//// //// //// //// //// //// //// //// //// //// //// //// ////
				// Check if Server Data has the same type of Core Data Object.
				//// //// //// //// //// //// ///// //// // //// //// //// /////
				if ( ! [self checkIfObject:anObject       ofKey:dataKey
								 hasSameTypeOf:serverData ofKey:property] )
				{
					// if DONT → Try to convert. ➘ (Oh yeah!)
					serverData =  [self  tryToConvert:serverData    ofKey:property
									 toTheSameClassOf:anObject      ofKey:dataKey];
				}
				//// //// //// //// //// //// //// //// //// //////// //// //////// //// /////
				// Set Value if isn't NIL.
				if ( serverData != nil ) {

					// Validate first.
					NSError *anError;
					if ( ![anObject validateValue:&serverData forKey:dataKey error:&anError] ) {
						[NSException raise:anError.domain format:@"%@", [anError localizedDescription]];
						return nil;
					}

					// Set the value.
					[anObject setValue:serverData forKey:dataKey];
				}
			}
		}
	}

	// Return populated object.
	return anObject;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Populate Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)populateObject:(id)anObject withData:(NSDictionary*)anDictionary
		   usingMap:(NSDictionary*)anMap withDelegate:(id<TTDataPopulatorDelegate>)anDelegate {
	// Create an instance.
	TTDataPopulator *anInstance = [[[self alloc] init] autorelease];
	// Set delegate.
	anInstance.delegate = anDelegate;

	/////////////
	return [anInstance populateObject:anObject
							 withData:anDictionary
							 usingMap:anMap];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Populate the informed object with data.
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)populateObject:(id)anObject withData:(NSDictionary*)anDictionary
		   usingMap:(NSDictionary*)anMap {
	return [self populateObject:anObject withData:anDictionary usingMap:anMap withDelegate:nil];
}
///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ///// ////
@end
