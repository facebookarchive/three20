//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"

#define kStoreType      NSSQLiteStoreType
#define kStoreFilename  @"db.sqlite"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface AppDelegate()
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // Forcefully removes the model db and recreates it.
  //_resetModel = YES;

  TTNavigator* navigator = [TTNavigator navigator];
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;

  TTURLMap* map = navigator.URLMap;

  [map from:@"*" toViewController:[TTWebController class]];

  if (![navigator restoreViewControllers]) {
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"http://three20.info"]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_managedObjectContext);
  TT_RELEASE_SAFELY(_managedObjectModel);
  TT_RELEASE_SAFELY(_persistentStoreCoordinator);

	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)navigator:(TTNavigator*)navigator shouldOpenURL:(NSURL*)URL {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillTerminate:(UIApplication *)application {
  NSError* error = nil;
  if (_managedObjectContext != nil) {
    if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Core Data stack


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectContext*)managedObjectContext {
  if( _managedObjectContext != nil ) {
    return _managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    [_managedObjectContext setUndoManager:nil];
    [_managedObjectContext setRetainsRegisteredObjects:YES];
  }
  return _managedObjectContext;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectModel*)managedObjectModel {
  if( _managedObjectModel != nil ) {
    return _managedObjectModel;
  }
  _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
  return _managedObjectModel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)storePath {
  return [[self applicationDocumentsDirectory]
    stringByAppendingPathComponent: kStoreFilename];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL*)storeUrl {
  return [NSURL fileURLWithPath:[self storePath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)migrationOptions {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
  if( _persistentStoreCoordinator != nil ) {
    return _persistentStoreCoordinator;
  }

  NSString* storePath = [self storePath];
  NSURL *storeUrl = [self storeUrl];

	NSError* error;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
    initWithManagedObjectModel: [self managedObjectModel]];

  NSDictionary* options = [self migrationOptions];

  // Check whether the store already exists or not.
  NSFileManager* fileManager = [NSFileManager defaultManager];
  BOOL exists = [fileManager fileExistsAtPath:storePath];

  TTDINFO(storePath);
  if( !exists ) {
    _modelCreated = YES;
  } else {
    if( _resetModel ||
        [[NSUserDefaults standardUserDefaults] boolForKey:@"erase_all_preference"] ) {
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"erase_all_preference"];
      [fileManager removeItemAtPath:storePath error:nil];
      _modelCreated = YES;
    }
  }

  if (![_persistentStoreCoordinator
    addPersistentStoreWithType: kStoreType
                 configuration: nil
                           URL: storeUrl
                       options: options
                         error: &error
  ]) {
    // We couldn't add the persistent store, so let's wipe it out and try again.
    [fileManager removeItemAtPath:storePath error:nil];
    _modelCreated = YES;

    if (![_persistentStoreCoordinator
      addPersistentStoreWithType: kStoreType
                   configuration: nil
                             URL: storeUrl
                         options: nil
                           error: &error
    ]) {
      // Something is terribly wrong here.
    }
  }

  return _persistentStoreCoordinator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application's documents directory


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)applicationDocumentsDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
    lastObject];
}


@end

