
#import "WebTestController.h"

@implementation WebTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
  [self openURL:[NSURL URLWithString:@"http://github.com/joehewitt/three20/tree/master"]];
}

@end
