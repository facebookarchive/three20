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

#import <Foundation/Foundation.h>

/**
 * General-purpose information about the Three20 ecosystem.
 *
 * This information is present in the core because Three20 versioning is done across all of
 * the primary Three20 modules.
 *
 * This is the only object in the Three20 ecosystem that doesn't follow the standard TT* prefix.
 * This is by design. [Three20 version] is much clearer than [TTVersion version].
 */
@interface Three20 : NSObject


#pragma mark -
#pragma mark General Purpose Version Information

/**
 * @see Three20Version
 */
+ (NSString*)version;


#pragma mark -
#pragma mark Version Breakdown

/**
 * Major release number.
 *
 * Major releases involve large structural changes that will break compatibility
 * with older versions.
 */
+ (NSInteger)majorVersion;

/**
 * Minor release number.
 *
 * Minor releases involve minimal structural changes that might break compatibility
 * with older versions but should only involve minimal effort to transition to.
 */
+ (NSInteger)minorVersion;

/**
 * Bugfix release number.
 *
 * Bugfix releases involve no structural modifications, but may introduce new code and
 * fix existing bugs.
 */
+ (NSInteger)bugfixVersion;

/**
 * Hotfix release number.
 *
 * Hotfix releases fix crashing bugs and compilation errors that may have slipped through the
 * release process.
 */
+ (NSInteger)hotfixVersion;

@end
