#import "TestController.h"

@implementation TestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _label = nil;
    
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0] autorelease];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_label);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  self.view.backgroundColor = [UIColor whiteColor];
  
  _label = [[UILabel alloc] initWithFrame:self.view.bounds];
  _label.text = @"CONTROLLER ?";
  [self.view addSubview:_label];
}

- (void)showCaption:(int)caption {
  self.view;
  _label.text = [NSString stringWithFormat:@"CONTROLLER %d", caption];
}

@end
