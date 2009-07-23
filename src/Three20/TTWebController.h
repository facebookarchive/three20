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
