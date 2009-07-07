
#import "WebTestController.h"

@implementation WebTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (id)init {
  return [super init];
}

- (void)viewDidLoad {
  [self openURL:[NSURL URLWithString:@"http://github.com/joehewitt/three20/tree/master"]];
}

@end
