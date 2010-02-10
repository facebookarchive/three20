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

/**
 * Returns TRUE if the URL begins with "bundle://"
 */
BOOL TTIsBundleURL(NSString* URL);

/**
 * Returns TRUE if the URL begins with "documents://"
 */
BOOL TTIsDocumentsURL(NSString* URL);

/**
 * Returns the main bundle path concatenated with the given relative path.
 */
NSString* TTPathForBundleResource(NSString* relativePath);

/**
 * Returns the documents path concatenated with the given relative path.
 */
NSString* TTPathForDocumentsResource(NSString* relativePath);
