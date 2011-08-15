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
 * Expressed in MAJOR.MINOR.BUGFIX(.HOTFIX) notation.
 *
 * For example, 1.0.5.1 is:
 *  - the first major release,
 *  - with no minor updates,
 *  - with 5 bugfix patches,
 *  - and 1 hotfix patch.
 *
 * The .HOTFIX version will only be present if hotfixVersion is > 0.
 *
 * Check out the versionStringCompare: addition to NSString if you need to compare Three20
 * versions. You will need to import Three20+Additions.h in order to use it.
 */
extern NSString* const Three20Version;
