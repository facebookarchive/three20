#import "Three20/TTWebController.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTURLCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTWebController

@synthesize delegate = _delegate, headerView = _headerView;

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
    cancelButtonTitle:TTLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil
    otherButtonTitles:TTLocalizedString(@"Open in Safari", @""), nil] autorelease];
  [sheet showInView:self.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSURL*)URL {
  if (self = [self init]) {
    [self openURL:URL];
  }
  return self;
}

- (id)initWithURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self init]) {
    NSURLRequest* request = [query objectForKey:@"request"];
    if (request) {
      [self openRequest:request];
    } else {
      [self openURL:URL];
    }
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _loadingURL = nil;
    _webView = nil;
    _toolbar = nil;
    _headerView = nil;
    _backButton = nil;
    _forwardButton = nil;
    _stopButton = nil;
    _refreshButton = nil;
    
    self.hidesBottomBarWhenPushed = YES;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_loadingURL);
  TT_RELEASE_MEMBER(_headerView);
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
    CGRectMake(0, self.view.height - TT_ROW_HEIGHT, self.view.width, TT_ROW_HEIGHT)];
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _toolbar.tintColor = TTSTYLEVAR(navigationBarTintColor);
  _toolbar.items = [NSArray arrayWithObjects:
    _backButton, space, _forwardButton, space, _refreshButton, space, actionButton, nil];
  [self.view addSubview:_toolbar];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  _webView.delegate = nil;
  TT_RELEASE_MEMBER(_webView);
  TT_RELEASE_MEMBER(_toolbar);
  TT_RELEASE_MEMBER(_backButton);
  TT_RELEASE_MEMBER(_forwardButton);
  TT_RELEASE_MEMBER(_refreshButton);
  TT_RELEASE_MEMBER(_stopButton);
  TT_RELEASE_MEMBER(_activityItem);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

- (void)persistView:(NSMutableDictionary*)state {
  NSString* URL = self.URL.absoluteString;
  if (URL) {
    [state setObject:URL forKey:@"URL"];
  }
}

- (void)restoreView:(NSDictionary*)state {
  NSString* URL = [state objectForKey:@"URL"];
  if (URL) {
    [self openURL:[NSURL URLWithString:URL]];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
        navigationType:(UIWebViewNavigationType)navigationType {
  [_loadingURL release];
  _loadingURL = [request.URL retain];
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
  self.title = TTLocalizedString(@"Loading...", @"");
  if (!self.navigationItem.rightBarButtonItem) {
    self.navigationItem.rightBarButtonItem = _activityItem;
  }
  [_toolbar replaceItemWithTag:3 withItem:_stopButton];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}


- (void)webViewDidFinishLoad:(UIWebView*)webView {
  TT_RELEASE_MEMBER(_loadingURL);
  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  if (self.navigationItem.rightBarButtonItem == _activityItem) {
    self.navigationItem.rightBarButtonItem = nil;
  }
  [_toolbar replaceItemWithTag:3 withItem:_refreshButton];
  [_webView canGoBack];
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
  TT_RELEASE_MEMBER(_loadingURL);
  [self webViewDidFinishLoad:webView];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [[UIApplication sharedApplication] openURL:self.URL];
  }
}
 
///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSURL*)URL {
  return _loadingURL ? _loadingURL : _webView.request.URL;
}

- (void)openRequest:(NSURLRequest*)request {
  self.view;
  [_webView loadRequest:request];
}

- (void)setHeaderView:(UIView*)headerView {
  if (headerView != _headerView) {
    BOOL addingHeader = !_headerView && headerView;
    BOOL removingHeader = _headerView && !headerView;

    [_headerView removeFromSuperview];
    [_headerView release];
    _headerView = [headerView retain];
    _headerView.frame = CGRectMake(0, 0, _webView.width, _headerView.height);

    self.view;
    UIView* scroller = [_webView descendantOrSelfWithClass:NSClassFromString(@"UIScroller")];
    UIView* docView = [scroller descendantOrSelfWithClass:NSClassFromString(@"UIWebDocumentView")];
    [scroller addSubview:_headerView];

    if (addingHeader) {
      docView.top += headerView.height;
      docView.height -= headerView.height; 
    } else if (removingHeader) {
      docView.top -= headerView.height;
      docView.height += headerView.height; 
    }
  }
}

- (void)openURL:(NSURL*)URL {
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
  [self openRequest:request];
}

@end
