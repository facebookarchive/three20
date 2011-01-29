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
#import <UIKit/UIKit.h>

/**
 * The extension loader provides basic utility methods to load extensions once an application
 * has started running.
 *
 *     [TTExtensionLoader loadAllExtensions];
 *
 * is likely the only method you'll need to use.
 *
 * How it works:
 *
 * An extension creates a TTExtensionLoader category, e.g.:
 *
 *     @interface TTExtensionLoader (TTXMLExtension)
 *
 * The extension then implements a method in this category with the prefix "loadExtensionNamed"
 *
 *     - (BOOL)loadExtensionNamedThree20XML;
 *
 * This method will be called when loadAllExtensions is called and should be used to initialize
 * any extension-specific functionality. A simple example of this might be to register some global
 * navigator URLs for use by the application.
 *
 * The extension can then optionally implement a second method with the prefix
 * "extensionInfoNamed". The text after the prefix should match that of the load method.
 *
 *     - (TTExtensionInfo*)extensionInfoNamedThree20XML;
 *
 * This method should return an autoreleased TTExtensionInfo object that has been populated with
 * any information the extension wishes to provide. If this method isn't implemented, a default
 * TTExtensionInfo object will be created.
 */
@interface TTExtensionLoader : NSObject {

}

/**
 * Load all extensions that provide a method of the following signature:
 * - (BOOL)loadExtensionNamed<extension name>
 *
 * For example:
 * - (BOOL)loadExtensionNamedThree20XML
 */
+ (void)loadAllExtensions;

/**
 * Retrieve the map of available extensions.
 *
 * Format:
 *  [(NSString*)identifier] => (TTExtensionInfo*)extension
 */
+ (NSDictionary*)availableExtensions;

/**
 * Retrieve the map of loaded extensions.
 *
 * Format:
 *  [(NSString*)identifier] => (TTExtensionInfo*)extension
 */
+ (NSDictionary*)loadedExtensions;

/**
 * Retrieve the map of extensions that failed to load.
 *
 * Format:
 *  [(NSString*)identifier] => (TTExtensionInfo*)extension
 */
+ (NSDictionary*)failedExtensions;

@end
