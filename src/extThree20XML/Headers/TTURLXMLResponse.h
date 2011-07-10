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

// Network
#import "Three20Network/TTURLResponse.h"

/**
 * An implementation of the TTURLResponse protocal for turning XML responses into NSObjects.
 *
 * This particular implementation uses a strict XML parser (NSXMLParser). It is not designed to
 * parse HTML pages that are likely to have invalid markup.
 */
@interface TTURLXMLResponse : NSObject <TTURLResponse> {
  id    _rootObject;
  BOOL  _isRssFeed;
}

@property (nonatomic, retain, readonly) id    rootObject;

/**
 * Is this XML response an RSS feed? This distinction is necessary in order to allow duplicate
 * keys in the XML objects.
 *
 * @default NO
 */
@property (nonatomic, assign)           BOOL  isRssFeed;

@end
