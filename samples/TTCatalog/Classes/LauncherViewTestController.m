#import "LauncherViewTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation LauncherViewTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    self.title = @"Launcher";
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
                                             
  _launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
  _launcherView.backgroundColor = [UIColor blackColor];
  _launcherView.delegate = self;
  _launcherView.pages = [NSArray arrayWithObjects:
    [NSArray arrayWithObjects:
      [[[TTLauncherItem alloc] initWithTitle:@"Button 1"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 2"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 3"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 4"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 5"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 6"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 7"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      nil],
    [NSArray arrayWithObjects:
      [[[TTLauncherItem alloc] initWithTitle:@"Button 8"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      [[[TTLauncherItem alloc] initWithTitle:@"Button 9"
                               image:@"bundle://Icon.png"
                               URL:nil] autorelease],
      nil],
      nil
    ];
  [self.view addSubview:_launcherView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLauncherViewDelegate

- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item {
}

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
    target:_launcherView action:@selector(endEditing)] autorelease] animated:YES];
}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

@end
