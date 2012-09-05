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

#import "Three20Core/TTGlobalCorePaths.h"


static NSBundle* globalBundle = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsBundleURL(NSString* URL) {
  return [URL hasPrefix:@"bundle://"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsDocumentsURL(NSString* URL) {
  return [URL hasPrefix:@"documents://"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL TTIsCachesURL(NSString* URL) {
  return [URL hasPrefix:@"cache://"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTSetDefaultBundle(NSBundle* bundle) {
  [bundle retain];
  [globalBundle release];
  globalBundle = bundle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSBundle* TTGetDefaultBundle() {
  return (nil != globalBundle) ? globalBundle : [NSBundle mainBundle];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* TTPathForBundleResource(NSString* relativePath) {
  NSString* resourcePath = [TTGetDefaultBundle() resourcePath];
  return [resourcePath stringByAppendingPathComponent:relativePath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* TTPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (nil == documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES);
    documentsPath = [[dirs objectAtIndex:0] retain];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* TTPathForCachesResource(NSString* relativePath) {
  static NSString* cachesPath = nil;
  if (nil == cachesPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(
      NSCachesDirectory, NSUserDomainMask, YES);
    cachesPath = [[dirs objectAtIndex:0] retain];
  }
  return [cachesPath stringByAppendingPathComponent:relativePath];
}

