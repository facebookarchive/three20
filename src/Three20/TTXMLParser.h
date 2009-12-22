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

extern NSString* kCommonXMLType_Unknown;

@protocol TTXMLParserDelegate;

/**
 * An implementation of the NSXMLParser object that turns XML into NSObjects.
 */
@interface TTXMLParser : NSXMLParser {
@private
  id              _rootObject;

  NSMutableArray* _objectStack;
}

@property (nonatomic, readonly) id rootObject;

@end

/**
 * Additions for accessing TTXMLParser results.
 */
@interface NSDictionary (TTXMLAdditions)

/**
 * @return The XML entity name.
 */
- (NSString*)nameForXMLNode;

/**
 * @return The XML entity type.
 */
- (NSString*)typeForXMLNode;

/**
 * @return The XML processed value for this object.
 */
- (id)objectForXMLNode;

@end
