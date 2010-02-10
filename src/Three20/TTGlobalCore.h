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

#import "Three20/TTCorePreprocessorMacros.h"

// Debugging
#import "Three20/TTDebug.h"

// Core Additions
#import "Three20/NSObjectAdditions.h"
#import "Three20/NSDataAdditions.h"
#import "Three20/NSStringAdditions.h"
#import "Three20/NSArrayAdditions.h"
#import "Three20/NSMutableArrayAdditions.h"
#import "Three20/NSMutableDictionaryAdditions.h"
#import "Three20/NSDateAdditions.h"

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* TTCreateNonRetainingArray();

/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 */
NSMutableDictionary* TTCreateNonRetainingDictionary();

/**
 * Tests if an object is an array which is not empty.
 */
BOOL TTIsArrayWithItems(id object);

/**
 * Tests if an object is a set which is not empty.
 */
BOOL TTIsSetWithItems(id object);

/**
 * Tests if an object is a string which is not empty.
 */
BOOL TTIsStringWithAnyText(id object);

/**
 * Swap the two method implementations on the given class.
 * Uses method_exchangeImplementations to accomplish this.
 */
void TTSwapMethods(Class cls, SEL originalSel, SEL newSel);
