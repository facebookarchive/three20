//
// Copyright 2009-2010 Facebook
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

#import <Foundation/Foundation.h>

#import "Three20Core/TTCorePreprocessorMacros.h" // For __TTDEPRECATED_METHOD

@interface NSArray (TTCategory)

/**
 * Calls performSelector on all objects in the array.
 *
 * Deprecated May 25, 2010.
 * Rationale: makeObjectsPerformSelector accomplishes the same thing and is actually part
 * of the SDK, therefore it is likely more finely tuned.
 * Use instead: makeObjectsPerformSelector (see below)
 */
- (void)perform:(SEL)selector __TTDEPRECATED_METHOD;
- (void)perform:(SEL)selector withObject:(id)p1 __TTDEPRECATED_METHOD;
- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2 __TTDEPRECATED_METHOD;
- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
  __TTDEPRECATED_METHOD;

/**
 * Extensions to makeObjectsPerformSelector to provide support for more than one object
 * parameter.
 */
- (void)makeObjectsPerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2;
- (void)makeObjectsPerformSelector: (SEL)selector
                        withObject: (id)p1
                        withObject: (id)p2
                        withObject: (id)p3;

/**
 * @return nil or an object that matches value with isEqual:
 */
- (id)objectWithValue:(id)value forKey:(id)key;

/**
 * @return the first object with the given class.
 */
- (id)objectWithClass:(Class)cls;

/**
 * @param selector Required format: - (NSNumber*)method:(id)object;
 */
- (BOOL)containsObject:(id)object withSelector:(SEL)selector;

@end
