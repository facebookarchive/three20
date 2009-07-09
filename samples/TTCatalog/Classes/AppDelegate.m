#import "AppDelegate.h"
#import "CatalogController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "TableImageTestController.h"
#import "YouTubeTestController.h"
#import "TableItemTestController.h"
#import "TableControlsTestController.h"
#import "TableTestController.h"
#import "SearchTestController.h"
#import "MessageTestController.h"
#import "ActivityTestController.h"
#import "ScrollViewTestController.h"
#import "StyledTextTestController.h"
#import "StyledTextTableTestController.h"
#import "StyleTestController.h"
#import "ButtonTestController.h"
#import "TabBarTestController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTURLMap* urls = [TTURLMap urlMap];
  [urls addURL:@"*" create:[TTWebController class] selector:@selector(initWithURL:)];
  [urls addURL:@"tt://catalog" create:[CatalogController class]];
  [urls addURL:@"tt://photoTest1" create:[PhotoTest1Controller class]];
  [urls addURL:@"tt://photoTest2" create:[PhotoTest2Controller class]];
  [urls addURL:@"tt://imageTest1" create:[ImageTest1Controller class]];
  [urls addURL:@"tt://tableTest" create:[TableTestController class]];
  [urls addURL:@"tt://tableItemTest" create:[TableItemTestController class]];
  [urls addURL:@"tt://tableControlsTest" create:[TableControlsTestController class]];
  [urls addURL:@"tt://styledTextTableTest" create:[StyledTextTableTestController class]];
  [urls addURL:@"tt://composerTest" create:[MessageTestController class]];
  [urls addURL:@"tt://searchTest" create:[SearchTestController class]];
  [urls addURL:@"tt://activityTest" create:[ActivityTestController class]];
  [urls addURL:@"tt://styleTest" create:[StyleTestController class]];
  [urls addURL:@"tt://styledTextTest" create:[StyledTextTestController class]];
  [urls addURL:@"tt://buttonTest" create:[ButtonTestController class]];
  [urls addURL:@"tt://tabBarTest" create:[TabBarTestController class]];
  [urls addURL:@"tt://youTubeTest" create:[YouTubeTestController class]];
  [urls addURL:@"tt://imageTest2" create:[TableImageTestController class]];
  [urls addURL:@"tt://scrollViewTest" create:[ScrollViewTestController class]];

  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;
  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://catalog" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

@end
