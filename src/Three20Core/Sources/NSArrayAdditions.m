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

#import "Three20Core/NSArrayAdditions.h"

#import "Three20Core/NSObjectAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
@implementation NSArray (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)perform:(SEL)selector {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector];
    }
  }
  [copy release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)perform:(SEL)selector withObject:(id)p1 {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector withObject:p1];
    }
  }
  [copy release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2 {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector withObject:p1 withObject:p2];
    }
  }
  [copy release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
  NSArray *copy = [[NSArray alloc] initWithArray:self];
  NSEnumerator* e = [copy objectEnumerator];
  for (id delegate; (delegate = [e nextObject]); ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector withObject:p1 withObject:p2 withObject:p3];
    }
  }
  [copy release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)makeObjectsPerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 {
  for (id delegate in self) {
    [delegate performSelector:selector withObject:p1 withObject:p2];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)makeObjectsPerformSelector: (SEL)selector
                        withObject: (id)p1
                        withObject: (id)p2
                        withObject: (id)p3 {
  for (id delegate in self) {
    [delegate performSelector:selector withObject:p1 withObject:p2 withObject:p3];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectWithValue:(id)value forKey:(id)key {
  for (id object in self) {
    id propertyValue = [object valueForKey:key];
    if ([propertyValue isEqual:value]) {
      return object;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectWithClass:(Class)cls {
  for (id object in self) {
    if ([object isKindOfClass:cls]) {
      return object;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)containsObject:(id)object withSelector:(SEL)selector {
  for (id item in self) {
    if ([[item performSelector:selector withObject:object] boolValue]) {
      return YES;
    }
  }
  return NO;
}


@end
