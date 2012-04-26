//
// Copyright 2012 RIKSOF
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

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

/**
 * Make room for the object at the top and insert it.
 */
- (void)push:(id)obj {
    // Always insert at the top.
    [self insertObject:obj atIndex:0];
}

/**
 * Remove the first object and return it.
 */
- (id)pop {
    // Get the object.
    id obj = nil;
    
    if ( self.count > 0 ) {
        obj = [self objectAtIndex:0];
    
        // Remove the object from the stack.
        [self removeObjectAtIndex:0];
    }
    
    return obj;
}

@end
