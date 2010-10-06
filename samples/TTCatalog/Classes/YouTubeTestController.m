#import "YouTubeTestController.h"
#import <Three20UI/UIViewAdditions.h>

@implementation YouTubeTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    youTubeView = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(youTubeView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  self.view.backgroundColor = [UIColor redColor];

  youTubeView = [[TTYouTubeView alloc] initWithURLPath:@"http://www.youtube.com/watch?v=g8thp78oXsg"];
  youTubeView.center = CGPointMake(self.view.width/2, 150);
  [self.view addSubview:youTubeView];

  UILabel* label = [[[UILabel alloc] init] autorelease];
  label.text = @"TTYouTubeView does not work in the iPhone Simulator";
  label.frame = CGRectMake(10, 10, 300, 30);
  label.backgroundColor = [UIColor redColor];
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont boldSystemFontOfSize:11];
  label.textAlignment = UITextAlignmentCenter;
  [self.view addSubview:label];
}

@end
