/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTGlobalCorePaths.h"

BOOL TTIsBundleURL(NSString* URL) {
  if (URL.length >= 9) {
    return [URL rangeOfString:@"bundle://" options:0 range:NSMakeRange(0,9)].location == 0;
  } else {
    return NO;
  }
}

BOOL TTIsDocumentsURL(NSString* URL) {
  if (URL.length >= 12) {
    return [URL rangeOfString:@"documents://" options:0 range:NSMakeRange(0,12)].location == 0;
  } else {
    return NO;
  }
}

NSString* TTPathForBundleResource(NSString* relativePath) {
  NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
  return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* TTPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (!documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsPath = [[dirs objectAtIndex:0] retain];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}
