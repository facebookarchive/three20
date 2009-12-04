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

#import "Three20/TTModelViewController.h"

@protocol TTWebControllerDelegate;

@interface TTWebController : TTModelViewController <UIWebViewDelegate, UIActionSheetDelegate> {
  id<TTWebControllerDelegate> _delegate;
  UIWebView* _webView;
  UIToolbar* _toolbar;
  UIView* _headerView;
  UIBarButtonItem* _backButton;
  UIBarButtonItem* _forwardButton;
  UIBarButtonItem* _refreshButton;
  UIBarButtonItem* _stopButton;
  UIBarButtonItem* _activityItem;
  NSURL* _loadingURL;
}

@property(nonatomic,assign) id<TTWebControllerDelegate> delegate;
@property(nonatomic,readonly) NSURL* URL;
@property(nonatomic,retain) UIView* headerView;

- (void)openURL:(NSURL*)URL;
- (void)openRequest:(NSURLRequest*)request;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTWebControllerDelegate <NSObject>
// XXXjoe Need to make this similar to UIWebViewDelegate
@end
