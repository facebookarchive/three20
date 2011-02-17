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
    map = controller.rightNavigator.URLMap;

  } else {
    [map                    from: @"tt://catalog"
          toSharedViewController: [CatalogController class]];
  }

  [map            from: @"tt://photoTest1"
                parent: @"tt://catalog"
      toViewController: [PhotoTest1Controller class]
              selector: nil
            transition: 0];
  [map            from: @"tt://photoTest2"
                parent: @"tt://catalog"
      toViewController: [PhotoTest2Controller class]
              selector: nil
            transition: 0];

  [map            from: @"tt://imageTest1"
                parent: @"tt://catalog"
      toViewController: [ImageTest1Controller class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tableTest"
                parent: @"tt://catalog"
      toViewController: [TableTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tableItemTest"
                parent: @"tt://catalog"
      toViewController: [TableItemTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tableControlsTest"
                parent: @"tt://catalog"
      toViewController: [TableControlsTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://styledTextTableTest"
                parent: @"tt://catalog"
      toViewController: [StyledTextTableTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tableWithShadow"
                parent: @"tt://catalog"
      toViewController: [TableWithShadowController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tableWithBanner"
                parent: @"tt://catalog"
      toViewController: [TableWithBannerController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tableDragRefresh"
                parent: @"tt://catalog"
      toViewController: [TableDragRefreshController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://composerTest"
                parent: @"tt://catalog"
      toViewController: [MessageTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://searchTest"
                parent: @"tt://catalog"
      toViewController: [SearchTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://activityTest"
                parent: @"tt://catalog"
      toViewController: [ActivityTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://styleTest"
                parent: @"tt://catalog"
      toViewController: [StyleTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://styledTextTest"
                parent: @"tt://catalog"
      toViewController: [StyledTextTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://buttonTest"
                parent: @"tt://catalog"
      toViewController: [ButtonTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://tabBarTest"
                parent: @"tt://catalog"
      toViewController: [TabBarTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://youTubeTest"
                parent: @"tt://catalog"
      toViewController: [YouTubeTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://imageTest2"
                parent: @"tt://catalog"
      toViewController: [TableImageTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://scrollViewTest"
                parent: @"tt://catalog"
      toViewController: [ScrollViewTestController class]
              selector: nil
            transition: 0];

  [map            from: @"tt://launcherTest"
                parent: @"tt://catalog"
      toViewController: [LauncherViewTestController class]
              selector: nil
            transition: 0];

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
