// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTPostController.h"
#import "Three20/TTStyle.h"
#import "Three20/TTStyleSheet.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTActivityLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 6;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPostController

@synthesize delegate = _delegate, result = _result, textEditor = _textEditor, 
            originView = _originView;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (NSString*)stripWhitespace:(NSString*)text {
  if (text) {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
    return [text stringByTrimmingCharactersInSet:whitespace];
  } else {
    return @"";
  }
}

- (void)showKeyboard {
  UIApplication* app = [UIApplication sharedApplication];
  _originalStatusBarStyle = app.statusBarStyle;
  _originalStatusBarHidden = app.statusBarHidden;
  if (!_originalStatusBarHidden) {
    [app setStatusBarHidden:NO animated:YES];
    [app setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
  }
  [_textEditor.textView becomeFirstResponder];
}

- (void)hideKeyboard {
  UIApplication* app = [UIApplication sharedApplication];
  [app setStatusBarHidden:_originalStatusBarHidden animated:YES];
  [app setStatusBarStyle:_originalStatusBarStyle animated:NO];
  [_textEditor.textView resignFirstResponder];
}

- (void)showActivity:(NSString*)activityText {
  if (!_activityView) {
    _activityView = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox];
    [self.view addSubview:_activityView];
  }

  if (activityText) {
    _activityView.text = activityText;
    _activityView.frame = CGRectOffset(CGRectInset(_textEditor.frame, 13, 13), 2, 0);
    _activityView.hidden = NO;
    _textEditor.textView.hidden = YES;
  } else {
    _activityView.hidden = YES;
    _textEditor.textView.hidden = NO;
  }
}

- (void)enableButtons:(BOOL)enabled {
  for (int i = 1; i < _navigationBar.items.count; ++i) {
    UIBarButtonItem* item = [_navigationBar.items objectAtIndex:i];
    item.enabled = enabled;
  }
}

- (void)layoutTextEditor {
  _textEditor.frame = CGRectMake(kMarginX, kMarginY+_navigationBar.height, self.view.width - kMarginX*2,
                                self.view.height - (TT_KEYBOARD_HEIGHT+_navigationBar.height+kMarginY*2));
  _textEditor.textView.hidden = NO;
}

- (void)showAnimationDidStop {
  _textEditor.textView.hidden = NO;
}

- (void)dismissAnimationDidStop {
  if ([_delegate respondsToSelector:@selector(postController:didPostText:withResult:)]) {
    [_delegate postController:self didPostText:_textEditor.text withResult:_result];
  }
  
  TT_RELEASE_SAFELY(_originView);
  [self dismissPopupViewControllerAnimated:NO];
}

- (void)fadeOut {
  _originView.hidden = NO;
  TT_RELEASE_SAFELY(_originView);
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(fadeAnimationDidStop)];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  self.view.alpha = 0;
  [UIView commitAnimations];
  
  [self hideKeyboard];
}

- (void)fadeAnimationDidStop {
  [self dismissPopupViewControllerAnimated:NO];
}

- (void)dismissWithCancel {
  if ([_delegate respondsToSelector:@selector(postControllerDidCancel:)]) {
    [_delegate postControllerDidCancel:self];
  }
  
  [self dismissPopupViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [super init]) {
    _delegate = nil;
    _result = nil;
    _defaultText = nil;
    _originRect = CGRectZero;
    _originView = nil;
    _textEditor = nil;
    _screenView = nil;
    _navigationBar = nil;
    _activityView = nil;

    if (query) {
      _delegate = [query objectForKey:@"delegate"];
      _defaultText = [[query objectForKey:@"text"] copy];
      
      self.navigationItem.title = [query objectForKey:@"title"];
      
      self.originView = [query objectForKey:@"__target__"];
      NSValue* originRect = [query objectForKey:@"originRect"];
      if (originRect) {
        _originRect = [originRect CGRectValue];
      }
    }

    self.navigationItem.leftBarButtonItem = 
      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = 
      [[[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"Done", @"")
                                style:UIBarButtonItemStyleDone
                                target:self action:@selector(post)] autorelease];
  }
  return self;
}

- (id)init {
  return [self initWithNavigatorURL:nil query:nil];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_result);
  TT_RELEASE_SAFELY(_defaultText);
  TT_RELEASE_SAFELY(_originView);
  TT_RELEASE_SAFELY(_textEditor);
  TT_RELEASE_SAFELY(_navigationBar);
  TT_RELEASE_SAFELY(_screenView);
  TT_RELEASE_SAFELY(_activityView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  self.view.frame = [UIScreen mainScreen].applicationFrame;
  self.view.backgroundColor = [UIColor clearColor];
  
  _screenView = [[UIView alloc] init];
  _screenView.backgroundColor = [UIColor blackColor];
  [self.view addSubview:_screenView];

  _textEditor = [[TTTextEditor alloc] init];
  _textEditor.textDelegate = self;
  _textEditor.autoresizesToText = NO;
  _textEditor.textView.font = TTSTYLEVAR(font);
  _textEditor.textView.textColor = [UIColor blackColor];
  _textEditor.textView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
  _textEditor.textView.keyboardAppearance = UIKeyboardAppearanceAlert;
  _textEditor.backgroundColor = [UIColor clearColor];
  _textEditor.style = TTSTYLE(postTextEditor);
  [self.view addSubview:_textEditor];

  _navigationBar = [[UINavigationBar alloc] init];
  _navigationBar.barStyle = UIBarStyleBlackOpaque;
  [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
  [self.view addSubview:_navigationBar];    
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  [state setObject:[NSNumber numberWithBool:YES] forKey:@"__important__"];

  NSString* delegate = [[TTNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
  [state setObject:self.textEditor.text forKey:@"text"];
  
  NSString* title = self.navigationItem.title;
  
  if (title) {
    [state setObject:title forKey:@"title"];
  }
  
  return [super persistView:state];
}

- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  NSString* delegate = [state objectForKey:@"delegate"];
  if (delegate) {
    _delegate = [[TTNavigator navigator] objectForPath:delegate];
  }
  NSString* title = [state objectForKey:@"title"];
  if (title) {
    self.navigationItem.title = title;
  }
  _defaultText = [[state objectForKey:@"text"] retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self retain];
  UIWindow* window = view.window ? view.window : [UIApplication sharedApplication].keyWindow;
  [window addSubview:self.view];
  
  if (_defaultText) {
    _textEditor.text = _defaultText;
    TT_RELEASE_SAFELY(_defaultText);
  } else {
    _defaultText = [_textEditor.text retain];
  }
  
  [_navigationBar sizeToFit];
  _screenView.frame = self.view.bounds;
  _originView.hidden = YES;
      
  if (animated) {
    _screenView.alpha = 0;
    _navigationBar.alpha = 0;
    _textEditor.textView.hidden = YES;

    CGRect originRect = _originRect;
    if (CGRectIsEmpty(originRect) && _originView) {
      originRect = _originView.screenFrame;
    }

    if (!CGRectIsEmpty(originRect)) {
      _textEditor.frame = CGRectOffset(originRect, 0, -TTStatusHeight());
    } else {
      [self layoutTextEditor];
      _textEditor.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];
    
    _navigationBar.alpha = 1;
    _screenView.alpha = 1;
    
    if (originRect.size.width) {
      [self layoutTextEditor];
    } else {
      _textEditor.transform = CGAffineTransformIdentity;
    }

    [UIView commitAnimations];
  } else {
    _screenView.alpha = 1;
    _textEditor.transform = CGAffineTransformIdentity;
    [self layoutTextEditor];
  }
  
  [self showKeyboard];
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  if (animated) {
    [self fadeOut];
  } else {
    UIViewController* superController = self.superController;
    [self.view removeFromSuperview];
    [self release];
    superController.popupViewController = nil;
    [superController viewWillAppear:animated];
    [superController viewDidAppear:animated];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self dismissWithCancel];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTTextEditor*)textEditor {
  self.view;
  return _textEditor;
}

- (UINavigationBar*)navigatorBar {
  if (!_navigationBar) {
    self.view;
  }
  return _navigationBar;
}

- (void)setOriginView:(UIView*)view {
  if (view != _originView) {
    [_originView release];
    _originView = [view retain];
    _originRect = CGRectZero;
  }
}

- (void)post {
  BOOL shouldDismiss = [self willPostText:_textEditor.text];
  if ([_delegate respondsToSelector:@selector(postController:willPostText:)]) {
    shouldDismiss = [_delegate postController:self willPostText:_textEditor.text];
  }
  
  if (shouldDismiss) {
    [self dismissWithResult:nil animated:YES];
  } else {
    [self enableButtons:NO];
    [self showActivity:[self titleForActivity]];
  }
}

- (void)cancel {
  if (!_textEditor.text.isEmptyOrWhitespace
      && !(_defaultText && [_defaultText isEqualToString:_textEditor.text])) {
    UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
      TTLocalizedString(@"Cancel", @"")
      message:TTLocalizedString(@"Are you sure you want to cancel?", @"")
      delegate:self cancelButtonTitle:TTLocalizedString(@"Yes", @"")
      otherButtonTitles:TTLocalizedString(@"No", @""), nil] autorelease];
    [cancelAlertView show];
  } else {
    [self dismissWithCancel];
  }
}

- (void)dismissWithResult:(id)result animated:(BOOL)animated {
  [_result release];
  _result = [result retain];
  
  if (animated) {
    if ([_delegate respondsToSelector:@selector(postController:willAnimateTowards:)]) {
      CGRect rect = [_delegate postController:self willAnimateTowards:_originRect];
      if (!CGRectIsEmpty(rect)) {
        _originRect = rect;
      }
    }

    CGRect originRect = _originRect;
    if (CGRectIsEmpty(originRect) && _originView) {
      originRect = _originView.screenFrame;
    }

    _originView.hidden = NO;
    _activityView.hidden = YES;
    _textEditor.textView.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop)];
    
    if (!CGRectIsEmpty(originRect)) {
      _textEditor.frame = CGRectOffset(originRect, 0, -TTStatusHeight());
    } else {
      _textEditor.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }

    _textEditor.alpha = 0.5;
    _screenView.alpha = 0;
    _navigationBar.alpha = 0;
    
    [UIView commitAnimations];
  } else {
    [self dismissAnimationDidStop];
  }
  
  [self hideKeyboard];
}

- (void)failWithError:(NSError*)error {
  [self enableButtons:YES];
  [self showActivity:nil];
  
  NSString* title = [self titleForError:error];
  if (title.length) {
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Error", @"")
      message:title delegate:nil cancelButtonTitle:TTLocalizedString(@"Ok", @"")
      otherButtonTitles:nil] autorelease];
    [alertView show];
  }
}

- (BOOL)willPostText:(NSString*)text {
  return YES;
}

- (NSString*)titleForActivity {
  return nil;
}

- (NSString*)titleForError:(NSError*)error {
  return nil;
}

@end
