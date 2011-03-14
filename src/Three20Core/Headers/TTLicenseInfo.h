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

#import "Three20Core/TTLicense.h"

/**
 * Information about a given license.
 *
 * In general, the bare minimum of information is kept in Three20. Where possible,
 * more information about a given license may be found online through the URL path.
 */
@interface TTLicenseInfo : NSObject

/**
 * The full license name.
 */
+ (NSString*)nameForLicense:(TTLicense)license;

/**
 * The URL path of the full license.
 */
+ (NSString*)urlPathForLicense:(TTLicense)license;

/**
 * The license preamble with the given information inserted where necessary.
 */
+ (NSString*)preambleForLicense: (TTLicense)license
              withCopyrightYear: (NSString*)copyrightYear
             withCopyrightOwner: (NSString*)copyrightOwner;

@end
