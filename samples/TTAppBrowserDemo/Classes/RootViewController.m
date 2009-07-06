#import "RootViewController.h"
#import "Three20/developer.h"

@implementation RootViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
  TTAppBrowser* browser = [TTAppBrowser sharedBrowser];
  browser.mainViewController = self.navigationController;
  browser.delegate = self;
  browser.supportsShakeToReload = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [TTSectionedDataSource dataSourceWithObjects:
    @"General",
    [TTTableTextItem itemWithText:@"Web Image" URL:@"tt://imageTest1"],
    [TTTableTextItem itemWithText:@"YouTube Player" URL:@"tt://youTubeTest"],
    [TTTableTextItem itemWithText:@"Web Browser" URL:@"tt://webTest"],
    [TTTableTextItem itemWithText:@"Activity Labels" URL:@"tt://activityTest"],
    [TTTableTextItem itemWithText:@"Scroll View" URL:@"tt://scrollViewTest"],
    nil];
}

@end
