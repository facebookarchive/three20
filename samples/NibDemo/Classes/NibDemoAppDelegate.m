//
//  NibDemoAppDelegate.m
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright Brush The Dog Inc 2010. All rights reserved.
//

#import "NibDemoAppDelegate.h"
#import "RootViewController.h"
#import "StyleSheet.h"

@implementation NibDemoAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;
  navigator.window = self.window; 

  [TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];

  
  TTURLMap* map = navigator.URLMap;
  [map from:@"*" toViewController:[TTWebController class]];
  [map from:@"tt://nib/(loadFromNib:)" toSharedViewController:self];
  [map from:@"tt://nib/(loadFromNib:)/(WithClass:)" toSharedViewController:self];
  [map from:@"tt://viewController/(loadFromVC:)" toSharedViewController:self];
  [map from:@"tt://root" toViewController:NSClassFromString(@"RootViewController")];
  [map from:@"tt://modal/(loadFromNib:)" toModalViewController:self];
  
  
  
  if (![navigator restoreViewControllers]) {
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://root"]];
  }
}

/*
 Loads the given viewcontroller from the nib
 */
-(UIViewController *)loadFromNib:(NSString *)nibName WithClass:className
{
	UIViewController * newController = [[ NSClassFromString(className) alloc]
                                      initWithNibName:nibName bundle:nil] ;  
	[newController autorelease];
	
	return newController;
}


/*
 Loads the given viewcontroller from the the nib with the same name as the 
 class
 */
-(UIViewController *)loadFromNib:(NSString *)className
{
  return [self loadFromNib:className WithClass:className];

}


/*
 Loads the given viewcontroller by name
 */
-(UIViewController *)loadFromVC:(NSString *)className
{
	UIViewController * newController = [[ NSClassFromString(className) alloc] init];  
	[newController autorelease];
	
	return newController;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}




- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}


@end

