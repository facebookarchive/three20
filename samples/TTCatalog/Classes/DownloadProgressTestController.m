#import "DownloadProgressTestController.h"
#import <Three20/Three20.h>
#import "DownloadTestModel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation DownloadProgressTestController

static const NSString *k1MBDownloadUrl = @"http://cachefly.cachefly.net/1mb.test";
static const NSString *k5MBDownloadUrl = @"http://cachefly.cachefly.net/5mb.test";
static const NSString *k10MBDownloadUrl = @"http://cachefly.cachefly.net/10mb.test";

static const NSString *k1MBDownloadTitle = @"Download 1MB File";
static const NSString *k5MBDownloadTitle = @"Download 5MB File";
static const NSString *k10MBDownloadTitle = @"Download 10MB File";
///////////////////////////////////////////////////////////////////////////////////////////////////
// initiation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Download Progress";
  }
  return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)loadWithUrl:(NSString*)url {
  TT_RELEASE_SAFELY(_loadingModel);
  _loadingModel = [[DownloadTestModel alloc] init];
  [_loadingModel.delegates addObject: self];
  [_loadingModel setDownloadUrl: url];
  [_loadingModel load: TTURLRequestCachePolicyNoCache more: NO];
}

- (void)updateProgress:(NSTimer*)timer {
  [_activityLabel setProgress: [_loadingModel downloadProgress]];
}

- (void)layout {
  TTGridLayout *gridLayout = [[[TTGridLayout alloc] init] autorelease];
  [gridLayout setColumnCount: 1];
  [gridLayout setSpacing: 20.0f];
  [gridLayout setPadding: 10.0f];
  
  CGSize size = [gridLayout layoutSubviews:self.view.subviews forView:self.view];
  
  UIScrollView *scrollView = (UIScrollView*)self.view;
  scrollView.contentSize = CGSizeMake(scrollView.width, size.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [self setView: [[[UIScrollView alloc] initWithFrame:TTNavigationFrame()] autorelease]];
  [self.view setBackgroundColor: [UIColor groupTableViewBackgroundColor]];
  
  TT_RELEASE_SAFELY(_activityLabel);
  _activityLabel = [[TTActivityLabel alloc] initWithStyle: TTActivityLabelStyleBlackBezel];
  [_activityLabel setText: @"View Loaded"];
  [self.view addSubview: _activityLabel];
  
  NSArray *buttons = [NSArray arrayWithObjects: 
                      [TTButton buttonWithStyle:@"toolbarRoundButton:" title:[k1MBDownloadTitle copy]],
                      [TTButton buttonWithStyle:@"toolbarRoundButton:" title:[k5MBDownloadTitle copy]],
                      [TTButton buttonWithStyle:@"toolbarRoundButton:" title:[k10MBDownloadTitle copy]],
                      nil];
  for (TTButton* button in buttons) {
    [button setFont: [UIFont systemFontOfSize: 16.0f]];
    [button sizeToFit];
    [button addTarget:self action:@selector(downloadButtonAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: button];
  }
  
  [self layout];
}

- (void)viewDidAppear:(BOOL)animated {
  _defaultMaxContentLength = [[TTURLRequestQueue mainQueue] maxContentLength];
  [[TTURLRequestQueue mainQueue] setMaxContentLength: 0];
  [[TTURLRequestQueue mainQueue] setSuspended: NO];
}

- (void)viewWillDisappear:(BOOL)animated {
  TT_RELEASE_SAFELY(_loadingModel);
  [[TTURLRequestQueue mainQueue] setMaxContentLength: _defaultMaxContentLength];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)downloadButtonAction:(TTButton*)button {
    if ([[button titleForState:UIControlStateNormal] isEqualToString: [k1MBDownloadTitle copy]]) {
      [self loadWithUrl: [k1MBDownloadUrl copy]];
    }
    else if ([[button titleForState:UIControlStateNormal] isEqualToString: [k5MBDownloadTitle copy]]) {
      [self loadWithUrl: [k5MBDownloadUrl copy]];
    }
    else if ([[button titleForState:UIControlStateNormal] isEqualToString: [k10MBDownloadTitle copy]]) {
      [self loadWithUrl: [k10MBDownloadUrl copy]];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate


- (void)modelDidStartLoad:(id <TTModel>)model {
  TT_INVALIDATE_TIMER(_progressTimer);
  _progressTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f/24.0f) target:self selector:@selector(updateProgress:) userInfo:nil repeats: YES];
  [_activityLabel setText:@"Download Started"];
  [_activityLabel setProgress: 0.0f];
}

- (void)modelDidFinishLoad:(id <TTModel>)model {
  TT_INVALIDATE_TIMER(_progressTimer);
  [_activityLabel setText:@"Download Finished"];
  [_activityLabel setProgress: 1.0f];
}

- (void)model:(id <TTModel>)model didFailLoadWithError:(NSError *)error {
  TT_INVALIDATE_TIMER(_progressTimer);
  [_activityLabel setText:@"Download Failed"];
  [_activityLabel setProgress: 0.0f];
}

- (void)modelDidCancelLoad:(id <TTModel>)model {
  TT_INVALIDATE_TIMER(_progressTimer);
  [_activityLabel setText:@"Download Canceled"];
  [_activityLabel setProgress: 0.0f];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
