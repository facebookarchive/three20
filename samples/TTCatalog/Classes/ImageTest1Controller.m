
#import "ImageTest1Controller.h"

@implementation ImageTest1Controller

- (void)loadView {
  self.view = [[[UIView alloc] init] autorelease];
  self.view.backgroundColor = [UIColor whiteColor];
  
  TTImageView* imageView = [[[TTImageView alloc] initWithFrame:CGRectMake(30, 30, 0, 0)]
    autorelease];
  imageView.autoresizesToImage = YES;
  imageView.urlPath = @"http://farm4.static.flickr.com/3163/3110335722_7a906f9d8b_m.jpg";
  [self.view addSubview:imageView];
}

- (void)dealloc {
	[super dealloc];
}

@end
