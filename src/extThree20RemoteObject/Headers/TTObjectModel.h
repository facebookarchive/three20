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

#import <objc/runtime.h>
#import "TTRemoteObject.h"

/**
 * This class is the parent for all objects that are retrieved from the server.
 */
@interface TTObjectModel : TTRemoteObject {
}

/**
 * Initialize the object from a document.
 */
- (void)decodeFromDocument:(id)doc;

/**
 * Build an xml document from this object.
 */
- (void)encodeToDocument:(id)doc;

/**
 * Builds an xml document with this element as the root.
 */
-(NSData *)toDocumentWithRoot:(NSString *)root;

/**
 * Serialize values to parameters.
 */
- (void)serializeToParameters;

@end
