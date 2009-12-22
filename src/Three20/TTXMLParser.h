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

@protocol TTXMLParserDelegate;

/**
 * A general-purpose XML parser.
 *
 * This parser is designed to easily allow entities to be created from the XML data.
 */
@interface TTXMLParser : NSXMLParser {
  id<TTXMLParserDelegate> _resultDelegate;

  /**
   * The stack of objects we're dealing with.
   */
  NSMutableArray* _objectStack;
}

@property (nonatomic, assign, getter = resultDelegate, setter = setResultDelegate)
  id<TTXMLParserDelegate> delegate;

@end


@interface NSDictionary (TTXMLAdditions)

- (id)objectForXMLValue;

@end


/**
 * The XML parser delegate.
 */
@protocol TTXMLParserDelegate <NSObject>
@required

/**
 * Called upon completion of parsing.
 */
- (void)didParseXML:(id)rootObject;

@optional
- (id)allocObjectForElementName: (NSString*) elementName
                     attributes: (NSDictionary*) attributeDict;

- (BOOL)addChild:(id)childObject toObject:(id)object;

- (BOOL)addCharacters: (NSString*)characters toObject:(id)object;

- (BOOL)performCleanupForObject:(id)object;

@end

