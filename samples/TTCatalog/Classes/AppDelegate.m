#import "AppDelegate.h"
#import "SplitCatalogController.h"
#import "CatalogController.h"
#import "PhotoTest1Controller.h"
#import "PhotoTest2Controller.h"
#import "ImageTest1Controller.h"
#import "TableImageTestController.h"
#import "YouTubeTestController.h"
#import "TableItemTestController.h"
#import "TableControlsTestController.h"
#import "TableTestController.h"
#import "TableWithBannerController.h"
#import "TableWithShadowController.h"
#import "TableDragRefreshController.h"
#import "SearchTestController.h"
#import "MessageTestController.h"
#import "ActivityTestController.h"
#import "ScrollViewTestController.h"
#import "LauncherViewTestController.h"
#import "StyledTextTestController.h"
#import "StyledTextTableTestController.h"
#import "StyleTestController.h"
#import "ButtonTestController.h"
#import "TabBarTestController.h"
#import "DownloadProgressTestController.h"

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;

  TTURLMap* map = navigator.URLMap;
  [map from:@"*" toViewController:[TTWebController class]];


  if (TTIsPad()) {
    [map                    from: @"tt://catalog"
          toSharedViewController: [SplitCatalogController class]];

    SplitCatalogController* controller =
      (SplitCatalogController*)[[TTNavigator navigator] viewControllerForURL:@"tt://catalog"];
    TTDASSERT([controller isKindOfClass:[SplitCatalogController class]]);
    map = controller.primaryNavigator.URLMap;

  } else {
    [map                    from: @"tt://catalog"
          toSharedViewController: [CatalogController class]];
  }

  [map            from: @"tt://photoTest1"
      toViewController: [PhotoTest1Controller class]];

  [map            from: @"tt://photoTest2"
      toViewController: [PhotoTest2Controller class]];

  [map            from: @"tt://imageTest1"
      toViewController: [ImageTest1Controller class]];

  [map            from: @"tt://tableTest"
      toViewController: [TableTestController class]];

  [map            from: @"tt://tableItemTest"
      toViewController: [TableItemTestController class]];

  [map            from: @"tt://tableControlsTest"
      toViewController: [TableControlsTestController class]];

  [map            from: @"tt://styledTextTableTest"
      toViewController: [StyledTextTableTestController class]];

  [map            from: @"tt://tableWithShadow"
      toViewController: [TableWithShadowController class]];

  [map            from: @"tt://tableWithBanner"
      toViewController: [TableWithBannerController class]];

  [map            from: @"tt://tableDragRefresh"
      toViewController: [TableDragRefreshController class]];

  [map            from: @"tt://composerTest"
      toViewController: [MessageTestController class]];

  [map            from: @"tt://searchTest"
      toViewController: [SearchTestController class]];

  [map            from: @"tt://activityTest"
      toViewController: [ActivityTestController class]];

  [map            from: @"tt://styleTest"
      toViewController: [StyleTestController class]];

  [map            from: @"tt://styledTextTest"
      toViewController: [StyledTextTestController class]];

  [map            from: @"tt://buttonTest"
      toViewController: [ButtonTestController class]];

  [map            from: @"tt://tabBarTest"
      toViewController: [TabBarTestController class]];

  [map            from: @"tt://youTubeTest"
      toViewController: [YouTubeTestController class]];

  [map            from: @"tt://imageTest2"
      toViewController: [TableImageTestController class]];

  [map            from: @"tt://scrollViewTest"
      toViewController: [ScrollViewTestController class]];

  [map            from: @"tt://launcherTest"
      toViewController: [LauncherViewTestController class]];

  [map            from: @"tt://dlprogress"
                parent: @"tt://catalog"
      toViewController: [DownloadProgressTestController class]
              selector: nil
            transition: 0];

  if (![navigator restoreViewControllers]) {
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://catalog"]];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}

@end
