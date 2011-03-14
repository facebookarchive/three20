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

#import "Three20UI/TTTableViewController.h"

@class TTNavigator;

/**
 * A list of all available, loaded, and failed extensions. This controller is used in
 * conjunction with the TTExtensionLoader found in Three20Core.
 * It is intended to provide helpful information about the extensions linked in the
 * application. It can also be used as a means of crediting the extensions whose
 * licenses require it.
 *
 * @see TTExtensionLoader
 */
@interface TTExtensionsController : TTTableViewController {

}


#pragma mark -
#pragma mark URL Path Registration

/**
 * Registers two URLs with the given navigator (e.g. with a prefix of @"tt://")
 *
 * * @"tt://extensions"                         -> [TTExtensionsController class]
 * * @"tt://extensions/(initWithExtensionID:)"  -> [TTExtensionInfoController class]
 *
 * You can use any prefix (e.g. @"myApp://three20/")
 *
 * * @"myApp://three20/extensions"                         -> [TTExtensionsController class]
 * * @"myApp://three20/extensions/(initWithExtensionID:)"  -> [TTExtensionInfoController class]
 */
+ (void)registerUrlPathsWithNavigator:(TTNavigator*)navigator prefix:(NSString*)prefix;


/**
 * URL path construction for opening extension controllers with TTNavigator.
 */
#pragma mark -
#pragma mark URL Path Construction

/**
 * The URL path for the extensions controller.
 *
 * This controller shows a list of all available extensions and whether or not they have
 * been loaded successfully.
 *
 * @param prefix  The same prefix used to register the URL paths.
 */
+ (NSString*)urlPathForExtensionsControllerWithPrefix:(NSString*)prefix;

/**
 * The URL path for a specific extension's information controller.
 *
 * @param prefix      The same prefix used to register the URL paths.
 * @param extensionId The extension identifier. A list of these identifiers can be obtained from
 *                    TTExtensionLoader.
 */
+ (NSString*)urlPathForExtensionInfoControllerWithPrefix: (NSString*)prefix
                                             extensionID: (NSString*)extensionId;

@end
