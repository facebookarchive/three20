#import "Three20/TTWebController.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTURLCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTWebController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)backAction {
  [_webView goBack];
}

- (void)forwardAction {
  [_webView goForward];
}

- (void)refreshAction {
  [_webView reload];
}

- (void)stopAction {
  [_webView stopLoading];
}

- (void)shareAction {
  UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"" delegate:self
    cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil
    otherButtonTitles:NSLocalizedString(@"Open in Safari", @""), nil] autorelease];
  [sheet showInView:self.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _webView = nil;
    _toolbar = nil;
    _stopButton = nil;
    _refreshButton = nil;
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
  
  _webView = [[UIWebView alloc] initWithFrame:TTToolbarNavigationFrame()];
  _webView.delegate = self;
  _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                              | UIViewAutoresizingFlexibleHeight;
  _webView.scalesPageToFit = YES;
  [self.view addSubview:_webView];

  UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc]
  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
  [spinner startAnimating];
  _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

  _backButton = [[UIBarButtonItem alloc] initWithImage:
    TTIMAGE(@"bundle://Three20.bundle/images/backIcon.png")
     style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
  _backButton.tag = 2;
  _backButton.enabled = NO;
  _forwardButton = [[UIBarButtonItem alloc] initWithImage:
    TTIMAGE(@"bundle://Three20.bundle/images/forwardIcon.png")
     style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction)];
  _forwardButton.tag = 1;
  _forwardButton.enabled = NO;
  _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
    UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
  _refreshButton.tag = 3;
  _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
    UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
  _stopButton.tag = 3;
  UIBarButtonItem* actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
    UIBarButtonSystemItemAction target:self action:@selector(shareAction)] autorelease];

  UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
   UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  _toolbar = [[UIToolbar alloc] initWithFrame:
    CGRectMake(0, self.view.height - TOOLBAR_HEIGHT, self.view.width, TOOLBAR_HEIGHT)];
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  _toolbar.tintColor = TTSTYLEVAR(navigationBarTintColor);
  _toolbar.items = [NSArray arrayWithObjects:
    _backButton, space, _forwardButton, space, _refreshButton, space, actionButton, nil];
  [self.view addSubview:_toolbar];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (void)unloadView {
  [super unloadView];
  [_webView release];
  _webView = nil;
  [_toolbar release];
  _toolbar = nil;
  [_backButton release];
  _backButton = nil;
  [_forwardButton release];
  _forwardButton = nil;
  [_refreshButton release];
  _refreshButton = nil;
  [_stopButton release];
  _stopButton = nil;
  [_activityItem release];
  _activityItem = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
        navigationType:(UIWebViewNavigationType)navigationType {
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
  self.title = NSLocalizedString(@"Loading...", @"");
  self.navigationItem.rightBarButtonItem = _activityItem;
  [_toolbar replaceItemWithTag:3 withItem:_stopButton];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}


- (void)webViewDidFinishLoad:(UIWebView*)webView {
  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  self.navigationItem.rightBarButtonItem = nil;
  [_toolbar replaceItemWithTag:3 withItem:_refreshButton];
  [_webView canGoBack];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
  [self webViewDidFinishLoad:webView];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [[UIApplication sharedApplication] openURL:_webView.request.URL];
  }
}
 
///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSURL*)url {
  return _webView.request.URL;
}

- (void)openURL:(NSURL*)url {
  self.view;
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  [_webView loadRequest:request];
}

@end
