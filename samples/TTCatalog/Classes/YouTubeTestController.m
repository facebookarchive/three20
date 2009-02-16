#import "YouTubeTestController.h"

@implementation YouTubeTestController

- (void)dealloc {
  [youTubeView release];
  [super dealloc];
}

- (void)loadView {
  self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
  self.view.backgroundColor = [UIColor redColor];
    
  youTubeView = [[TTYouTubeView alloc] initWithURL:@"http://www.youtube.com/watch?v=g8thp78oXsg"];
  youTubeView.center = CGPointMake(self.view.width/2, 100);
  [self.view addSubview:youTubeView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
