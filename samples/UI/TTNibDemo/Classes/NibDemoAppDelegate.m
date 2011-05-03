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

#import "NibDemoAppDelegate.h"
#import "RootViewController.h"
#import "StyleSheet.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NibDemoAppDelegate

@synthesize window                = _window;
@synthesize navigationController  = _navigationController;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(UIApplication *)application {
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;
  navigator.window = self.window;

  [TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];

  TTURLMap* map = navigator.URLMap;
  [map from:@"*" toViewController:[TTWebController class]];
  [map from:@"tt://root" toViewController:NSClassFromString(@"RootViewController")];
  [map from:@"tt://nib/(loadFromNib:)" toSharedViewController:self];
  [map from:@"tt://nib/(loadFromNib:)/(withClass:)" toSharedViewController:self];
  [map from:@"tt://viewController/(loadFromVC:)" toSharedViewController:self];
  [map from:@"tt://modal/(loadFromNib:)" toModalViewController:self];

  if (![navigator restoreViewControllers]) {
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://root"]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_navigationController);
  TT_RELEASE_SAFELY(_window);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller from the nib
 */
- (UIViewController*)loadFromNib:(NSString *)nibName withClass:className {
  UIViewController* newController = [[NSClassFromString(className) alloc]
                                      initWithNibName:nibName bundle:nil];
  [newController autorelease];

  return newController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller from the the nib with the same name as the
 * class
 */
- (UIViewController*)loadFromNib:(NSString*)className {
  return [self loadFromNib:className withClass:className];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller by name
 */
- (UIViewController *)loadFromVC:(NSString *)className {
  UIViewController * newController = [[ NSClassFromString(className) alloc] init];
  [newController autorelease];

  return newController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}


@end

