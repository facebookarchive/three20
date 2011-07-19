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
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "extThree20CSSStyle/TTDataConverter.h"
#import "extThree20CSSStyle/TTDataPopulatorDelegate.h"

/**
 * \nosubgrouping
 * TTDataPopulator is used to populate Model Objects with Data contained in dictionaries.
 * This is a little versio of this class with a small subset of useful methods to
 * use with 'TTCSS' Classes. See JUMP Framework to retrieve the full version.
 */
@interface TTDataPopulator : NSObject {
	id<TTDataPopulatorDelegate> delegate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties.
@property (assign) id<TTDataPopulatorDelegate> delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Populate Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////

//// //// //// //// //// //// //// //// //// //// //// //// //// //// ////
/** @name Populate Methods
 */
///@{

/**
 * Populate the informed object with data.
 * @param anObject The object to populate.
 * @param withData An <tt>NSDictionary</tt> with data.
 * @param usingMap An <tt>NSDictionary</tt> that represent an map that describe
 * how to populate the object.
 */
+(id)populateObject:(id)anObject withData:(NSDictionary*)anDictionary usingMap:(NSDictionary*)anMap;

/**
 * Populate the informed object with data.
 * @param anObject The object to populate.
 * @param withData An <tt>NSDictionary</tt> with data.
 * @param usingMap An <tt>NSDictionary</tt> that represent an map that describe
 * how to populate the object.
 * @param anDelegate to extend the TTDataPopulator class. See TTDataPopulatorDelegate
 * documentation for more information.
 */
+(id)populateObject:(id)anObject withData:(NSDictionary*)anDictionary usingMap:(NSDictionary*)anMap
	   withDelegate:(id<TTDataPopulatorDelegate>)anDelegate;

///@}
@end

