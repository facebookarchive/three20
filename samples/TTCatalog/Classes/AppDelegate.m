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
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;

  TTURLMap* map = navigator.URLMap;
  [map create:@"*" target:[TTWebController class] selector:@selector(initWithURL:)];
  [map create:@"tt://catalog" target:[CatalogController class]];
  [map create:@"tt://photoTest1" target:[PhotoTest1Controller class]];
  [map create:@"tt://photoTest2" target:[PhotoTest2Controller class]];
  [map create:@"tt://imageTest1" target:[ImageTest1Controller class]];
  [map create:@"tt://tableTest" target:[TableTestController class]];
  [map create:@"tt://tableItemTest" target:[TableItemTestController class]];
  [map create:@"tt://tableControlsTest" target:[TableControlsTestController class]];
  [map create:@"tt://styledTextTableTest" target:[StyledTextTableTestController class]];
  [map create:@"tt://composerTest" target:[MessageTestController class]];
  [map create:@"tt://searchTest" target:[SearchTestController class]];
  [map create:@"tt://activityTest" target:[ActivityTestController class]];
  [map create:@"tt://styleTest" target:[StyleTestController class]];
  [map create:@"tt://styledTextTest" target:[StyledTextTestController class]];
  [map create:@"tt://buttonTest" target:[ButtonTestController class]];
  [map create:@"tt://tabBarTest" target:[TabBarTestController class]];
  [map create:@"tt://youTubeTest" target:[YouTubeTestController class]];
  [map create:@"tt://imageTest2" target:[TableImageTestController class]];
  [map create:@"tt://scrollViewTest" target:[ScrollViewTestController class]];

  if (![navigator restoreViewControllers]) {
    [navigator openURL:@"tt://catalog" animated:NO];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURL:URL.absoluteString animated:NO];
  return YES;
}

@end
