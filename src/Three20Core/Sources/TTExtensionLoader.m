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

#import "Three20Core/TTExtensionLoader.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTExtensionInfo.h"

// Core (private)
#import "Three20Core/private/TTExtensionInfoPrivate.h"

#import <objc/runtime.h>

static NSString* kLoadExtensionMethodPrefix     = @"loadExtensionNamed";
static NSString* kExtensionInfoMethodPrefix     = @"extensionInfoNamed";

static NSMutableDictionary* sTTAvailableExtensions  = nil;
static NSMutableDictionary* sTTLoadedExtensions     = nil;
static NSMutableDictionary* sTTFailedExtensions     = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionLoader


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)callExtensionID:(NSString*)extensionID methodWithPrefix:(NSString*)prefix {
  SEL selector = NSSelectorFromString([prefix
                                       stringByAppendingString:extensionID]);

  id result = nil;
  if ([self respondsToSelector:selector]) {
    result = [self performSelector:selector];
  }
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTExtensionInfo*)extensionWithID:(NSString*)extensionID {
  TTExtensionInfo* extension = [self callExtensionID: extensionID
                                    methodWithPrefix: kExtensionInfoMethodPrefix];
  if (nil == extension) {
    extension = [[[TTExtensionInfo alloc] init] autorelease];
  }
  extension.identifier = extensionID;
  return extension;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadExtension:(TTExtensionInfo*)extension {
  BOOL succeeded = [self callExtensionID: extension.identifier
                        methodWithPrefix: kLoadExtensionMethodPrefix] ? YES : NO;

  if (succeeded) {
    [sTTLoadedExtensions setObject:extension forKey:extension.identifier];

  } else {
    [sTTFailedExtensions setObject:extension forKey:extension.identifier];
  }

  return succeeded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setupStaticData {
  if (nil == sTTLoadedExtensions) {
    sTTLoadedExtensions = [[NSMutableDictionary alloc] init];
  }
  if (nil == sTTFailedExtensions) {
    sTTFailedExtensions = [[NSMutableDictionary alloc] init];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)loadAllExtensions {
  [self setupStaticData];

  NSDictionary* availableExtensions = [self availableExtensions];

  if ([availableExtensions count] > 0) {
    TTExtensionLoader* loader = [[TTExtensionLoader alloc] init];

    for (NSString* extensionID in availableExtensions) {
      TTExtensionInfo* extension = [availableExtensions objectForKey:extensionID];
      [loader loadExtension:extension];
    }

    TT_RELEASE_SAFELY(loader);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDictionary*)availableExtensions {
  if (nil == sTTAvailableExtensions) {
    sTTAvailableExtensions = [[NSMutableDictionary alloc] init];

    unsigned int methodCount = 0;
    Method* methods = class_copyMethodList([self class], &methodCount);

    if (nil != methods) {
      TTExtensionLoader* loader = [[TTExtensionLoader alloc] init];

      for (unsigned int ix = 0; ix < methodCount; ++ix) {
        Method method = methods[ix];

        SEL methodSelector = method_getName(method);

        NSString* methodName = [NSString stringWithCString: sel_getName(methodSelector)
                                                  encoding: NSUTF8StringEncoding];

        if ([methodName hasPrefix:kLoadExtensionMethodPrefix]) {
          NSString* extensionID = [methodName substringFromIndex:
                                   [kLoadExtensionMethodPrefix length]];

          TTExtensionInfo* extension = [loader extensionWithID:extensionID];
          TTDASSERT(nil != extension);

          if (nil != extension) {
            [sTTAvailableExtensions setObject:extension forKey:extensionID];
          }
        }
      }

      TT_RELEASE_SAFELY(loader);
    }
  }

  return [NSDictionary dictionaryWithDictionary:sTTAvailableExtensions];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDictionary*)loadedExtensions {
  return [NSDictionary dictionaryWithDictionary:sTTLoadedExtensions];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDictionary*)failedExtensions {
  return [NSDictionary dictionaryWithDictionary:sTTFailedExtensions];
}


@end

