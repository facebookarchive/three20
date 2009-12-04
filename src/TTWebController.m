/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTWebController.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"

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

- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  _toolbar.height = TTToolbarHeight();
  _webView.height = self.view.height - _toolbar.height;
  _toolbar.top = self.view.height - _toolbar.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
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
  TT_RELEASE_SAFELY(_loadingURL);
  TT_RELEASE_SAFELY(_headerView);
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
    CGRectMake(0, self.view.height - TTToolbarHeight(), self.view.width, TTToolbarHeight())];
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _toolbar.tintColor = TTSTYLEVAR(navigationBarTintColor);
  _toolbar.items = [NSArray arrayWithObjects:
    _backButton, space, _forwardButton, space, _refreshButton, space, actionButton, nil];
  [self.view addSubview:_toolbar];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  _webView.delegate = nil;
  TT_RELEASE_SAFELY(_webView);
  TT_RELEASE_SAFELY(_toolbar);
  TT_RELEASE_SAFELY(_backButton);
  TT_RELEASE_SAFELY(_forwardButton);
  TT_RELEASE_SAFELY(_refreshButton);
  TT_RELEASE_SAFELY(_stopButton);
  TT_RELEASE_SAFELY(_activityItem);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateToolbarWithOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
  // If the browser launched the media player, it steals the key window and never gives it
  // back, so this is a way to try and fix that
  [self.view.window makeKeyWindow];

  [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
        duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateToolbarWithOrientation:toInterfaceOrientation];
}

- (UIView *)rotatingFooterView {
  return _toolbar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  NSString* URL = self.URL.absoluteString;
  if (URL.length) {
    [state setObject:URL forKey:@"URL"];
    return YES;
  } else {
    return NO;
  }
}

- (void)restoreView:(NSDictionary*)state {
  NSString* URL = [state objectForKey:@"URL"];
  if (URL.length && ![URL isEqualToString:@"about:blank"]) {
    [self openURL:[NSURL URLWithString:URL]];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
        navigationType:(UIWebViewNavigationType)navigationType {
  if ([[TTNavigator navigator].URLMap isAppURL:request.URL]) {
    [_loadingURL release];
    _loadingURL = [[NSURL URLWithString:@"about:blank"] retain];
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
  }
  
  [_loadingURL release];
  _loadingURL = [request.URL retain];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
  self.title = TTLocalizedString(@"Loading...", @"");
  if (!self.navigationItem.rightBarButtonItem) {
    [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
  }
  [_toolbar replaceItemWithTag:3 withItem:_stopButton];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}


- (void)webViewDidFinishLoad:(UIWebView*)webView {
  TT_RELEASE_SAFELY(_loadingURL);
  
  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  if (self.navigationItem.rightBarButtonItem == _activityItem) {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
  }
  [_toolbar replaceItemWithTag:3 withItem:_refreshButton];

  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];    
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_loadingURL);
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
