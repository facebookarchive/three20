#import "TabBarController.h"

@implementation TabBarController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
  [self setTabURLs:[NSArray arrayWithObjects:
    @"tt://test/1",
    @"tt://test/2",
    @"tt://test/3",
    @"tt://test/4",
    @"tt://test/5",
    nil]];
}

@end
