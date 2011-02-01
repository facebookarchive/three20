//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTWebController.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/TTView.h"
#import "Three20UI/TTButton.h"
#import "Three20UI/UIToolbarAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"
#import "Three20UINavigator/TTURLMap.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Style/TTStyleSheet.h"

// Network
#import "Three20Network/TTGlobalNetwork.h"
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"

static const CGFloat kAddressBarButtonsWidth = 240;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTWebController

@synthesize delegate    = _delegate;
@synthesize headerView  = _headerView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.hidesBottomBarWhenPushed = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self initWithNibName:nil bundle:nil]) {
    NSURLRequest* request = [query objectForKey:@"request"];

    if (nil != request) {
      [self openRequest:request];

    } else {
      [self openURL:URL];
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithNibName:nil bundle:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_loadingURL);
  TT_RELEASE_SAFELY(_headerView);
  TT_RELEASE_SAFELY(_actionSheet);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)backAction {
  [_webView goBack];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardAction {
  [_webView goForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshAction {
  [_webView reload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAction {
  [_webView stopLoading];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shareAction {
  if (nil == _actionSheet) {
    _actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                               delegate: self
                                      cancelButtonTitle: TTLocalizedString(@"Cancel", @"")
                                 destructiveButtonTitle: nil
                                      otherButtonTitles: TTLocalizedString(@"Open in Safari",
                                                                           @""),
                                                         nil];
    if (TTIsPad()) {
      [_actionSheet showFromBarButtonItem:_actionButton animated:YES];

    }  else {
      [_actionSheet showInView: self.view];
    }

  } else {
    [_actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    TT_RELEASE_SAFELY(_actionSheet);
  }

}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  _bottomView.height = TTToolbarHeight();
  _webView.height = self.view.height - _bottomView.height;
  _bottomView.top = self.view.height - _bottomView.height;
  _addressText.width = _bottomView.width - kAddressBarButtonsWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)createPhoneBottomView {
  UIActivityIndicatorView* spinner =
  [[[UIActivityIndicatorView alloc]
    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]
   autorelease];
  [spinner startAnimating];
  _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

  _backButton = [[UIBarButtonItem alloc] initWithImage:
                 TTIMAGE(@"bundle://Three20.bundle/images/backIcon.png")
                                                 style: UIBarButtonItemStylePlain
                                                target: self
                                                action: @selector(backAction)];
  _backButton.tag = 2;
  _backButton.enabled = NO;
  _forwardButton = [[UIBarButtonItem alloc] initWithImage:
                    TTIMAGE(@"bundle://Three20.bundle/images/forwardIcon.png")
                                                    style: UIBarButtonItemStylePlain
                                                   target: self
                                                   action: @selector(forwardAction)];
  _forwardButton.tag = 1;
  _forwardButton.enabled = NO;
  _refreshButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                                target: self
                                                action: @selector(refreshAction)];
  _refreshButton.tag = 3;
  _stopButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                target: self
                                                action: @selector(stopAction)];
  _stopButton.tag = 3;
  _actionButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction
                                                target: self
                                                action: @selector(shareAction)];

  // Create the toolbar view.

  UIBarItem* space =
  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                 target: nil
                                                 action: nil] autorelease];

  CGRect toolbarFrame = CGRectMake(0, self.view.height - TTToolbarHeight(),
                                   self.view.width, TTToolbarHeight());

  UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
  toolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                              | UIViewAutoresizingFlexibleWidth);
  toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);

  toolbar.items = [NSArray arrayWithObjects:
                   _backButton,
                   space,
                   _forwardButton,
                   space,
                   _refreshButton,
                   space,
                   _actionButton,
                   nil];
  _toolbar = [toolbar retain];
  return toolbar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)createPadBottomView {
  CGRect toolbarFrame = CGRectMake(0, self.view.height - TTToolbarHeight(),
                                   self.view.width, TTToolbarHeight());

  TTView* toolbarView = [[TTView alloc] initWithFrame:toolbarFrame];
  toolbarView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                  | UIViewAutoresizingFlexibleWidth);
  toolbarView.style = TTSTYLE(webViewToolbar);

  _backButton =
  [[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://Three20.bundle/images/backIcon.png")
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(backAction)];

  _forwardButton =
  [[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://Three20.bundle/images/forwardIcon.png")
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(forwardAction)];

  _refreshButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                                target: self
                                                action: @selector(refreshAction)];
  _refreshButton.tag = 3;
  _stopButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                target: self
                                                action: @selector(stopAction)];
  _stopButton.tag = 3;

  _addressText = [[UITextField alloc] initWithFrame:CGRectZero];
  _addressText.borderStyle = UITextBorderStyleRoundedRect;
  _addressText.text = [self.URL absoluteString];
  _addressText.height = 24;
  _addressText.width = toolbarFrame.size.width - kAddressBarButtonsWidth;
  _addressText.textColor = [UIColor grayColor];
  _addressText.font = [UIFont systemFontOfSize:14];
  _addressText.enabled = NO;

  _actionButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction
                                                target: self
                                                action: @selector(shareAction)];

  UIBarButtonItem* fixedWidth =
  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                 target:nil
                                                 action:nil] autorelease];
  fixedWidth.width = 20;

  UIToolbar* buttonToolbar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
  buttonToolbar.barStyle = -1;
  buttonToolbar.items = [NSArray arrayWithObjects:
                         fixedWidth,
                         _backButton,
                         fixedWidth,
                         _forwardButton,
                         fixedWidth,
                         _refreshButton,
                         fixedWidth,
                         _actionButton,
                         fixedWidth,
                         [[[UIBarButtonItem alloc] initWithCustomView:_addressText] autorelease],
                         nil];
  buttonToolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
  buttonToolbar.clipsToBounds = YES;
  buttonToolbar.width = toolbarView.width;
  buttonToolbar.height = toolbarView.height;

  [toolbarView addSubview:buttonToolbar];

  _toolbar = [buttonToolbar retain];

  return toolbarView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _webView = [[UIWebView alloc] initWithFrame:TTToolbarNavigationFrame()];
  _webView.delegate = self;
  _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleHeight);
  _webView.scalesPageToFit = YES;
  [self.view addSubview:_webView];

  if (TTIsPad()) {
    _bottomView = [self createPadBottomView];

  } else {
    _bottomView = [self createPhoneBottomView];
  }

  [self.view addSubview:_bottomView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];

  _webView.delegate = nil;

  TT_RELEASE_SAFELY(_webView);
  TT_RELEASE_SAFELY(_toolbar);
  TT_RELEASE_SAFELY(_bottomView);
  TT_RELEASE_SAFELY(_backButton);
  TT_RELEASE_SAFELY(_forwardButton);
  TT_RELEASE_SAFELY(_refreshButton);
  TT_RELEASE_SAFELY(_stopButton);
  TT_RELEASE_SAFELY(_actionButton);
  TT_RELEASE_SAFELY(_activityItem);
  TT_RELEASE_SAFELY(_addressText);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateToolbarWithOrientation:self.interfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  // If the browser launched the media player, it steals the key window and never gives it
  // back, so this is a way to try and fix that
  [self.view.window makeKeyWindow];

  [super viewWillDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateToolbarWithOrientation:toInterfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingFooterView {
  return _bottomView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UTViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  NSString* URL = self.URL.absoluteString;
  if (URL.length && ![URL isEqualToString:@"about:blank"]) {
    [state setObject:URL forKey:@"URL"];
    return YES;

  } else {
    return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
  NSString* URL = [state objectForKey:@"URL"];
  if (URL.length && ![URL isEqualToString:@"about:blank"]) {
    [self openURL:[NSURL URLWithString:URL]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)                webView: (UIWebView*)webView
     shouldStartLoadWithRequest: (NSURLRequest*)request
                 navigationType: (UIWebViewNavigationType)navigationType {
  if ([[TTNavigator navigator].URLMap isAppURL:request.URL]) {
    [_loadingURL release];
    _loadingURL = [[NSURL URLWithString:@"about:blank"] retain];
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
  }

  _addressText.text = [request.URL absoluteString];

  [_loadingURL release];
  _loadingURL = [request.URL retain];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(UIWebView*)webView {
  self.title = TTLocalizedString(@"Loading...", @"");
  if (!self.navigationItem.rightBarButtonItem) {
    [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
  }

  if (!TTIsPad()) {
    [(UIToolbar*)_toolbar replaceItemWithTag:3 withItem:_stopButton];
  }
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
  TT_RELEASE_SAFELY(_loadingURL);
  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  if (self.navigationItem.rightBarButtonItem == _activityItem) {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
  }
  if (!TTIsPad()) {
    [(UIToolbar*)_toolbar replaceItemWithTag:3 withItem:_refreshButton];
  }

  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_loadingURL);
  [self webViewDidFinishLoad:webView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [[UIApplication sharedApplication] openURL:self.URL];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL*)URL {
  return _loadingURL ? _loadingURL : _webView.request.URL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL:(NSURL*)URL {
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
  [self openRequest:request];
  _addressText.text = [URL absoluteString];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openRequest:(NSURLRequest*)request {
  self.view;
  [_webView loadRequest:request];
  _addressText.text = [request.URL absoluteString];
}


@end
