// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTPostController.h"
#import "Three20/TTStyle.h"
#import "Three20/TTStyleSheet.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTActivityLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 5;

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

- (void)showStatusBar {
  UIApplication* app = [UIApplication sharedApplication];
  _originalStatusBarStyle = app.statusBarStyle;
  _originalStatusBarHidden = app.statusBarHidden;
  if (!_originalStatusBarHidden) {
    [app setStatusBarHidden:NO animated:YES];
    [app setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
  }
}

- (void)showKeyboard {
  _toolbar.frame = CGRectMake(0, self.view.height - (_toolbar.height-1), 320, _toolbar.height);
  _toolbar.hidden = NO;

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.3];
  _toolbar.top -= TT_KEYBOARD_HEIGHT;
  [UIView commitAnimations];

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
  for (int i = 1; i < _toolbar.items.count; ++i) {
    UIBarButtonItem* item = [_toolbar.items objectAtIndex:i];
    item.enabled = enabled;
  }
}

- (void)layoutTextEditor {
  _textEditor.frame = CGRectMake(kMarginX, kMarginY, self.view.width - kMarginX*2,
                                self.view.height - (TT_KEYBOARD_HEIGHT+_toolbar.height+kMarginY*2));
  _textEditor.textView.hidden = NO;
}

- (void)springInAnimationStep2 {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.15];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(springInAnimationStep3)];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [self layoutTextEditor];
  [UIView commitAnimations];
}

- (void)springInAnimationStep3 {
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
  [UIView setAnimationDuration:0.3];
  self.view.alpha = 0;
  [UIView commitAnimations];
  
  [self hideKeyboard];
}

- (void)fadeAnimationDidStop {
  [self dismissPopupViewControllerAnimated:NO];
}

- (void)ensureToolbarItems {
  if (!self.toolbar.items.count) {
    self.toolbar.items = [NSArray arrayWithObjects:
      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                target:self action:@selector(cancel)] autorelease],
      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                target:nil action:nil] autorelease],
      [[[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"Done", @"")
                                style:UIBarButtonItemStyleDone
                                target:self action:@selector(post)] autorelease],
    nil];
  }
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
    _toolbar = nil;
    _activityView = nil;

    if (query) {
      _delegate = [query objectForKey:@"delegate"];
      _defaultText = [[query objectForKey:@"text"] copy];

      self.originView = [query objectForKey:@"__target__"];
      NSValue* originRect = [query objectForKey:@"originRect"];
      if (originRect) {
        _originRect = [originRect CGRectValue];
      }
    }
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
  TT_RELEASE_SAFELY(_toolbar);
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
  _textEditor.textView.font = [UIFont systemFontOfSize:15];
  _textEditor.textView.textColor = [UIColor blackColor];
  _textEditor.textView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
  _textEditor.textView.keyboardAppearance = UIKeyboardAppearanceAlert;
  _textEditor.backgroundColor = [UIColor clearColor];
  _textEditor.style = TTSTYLE(postBox);
  [self.view addSubview:_textEditor];

  _toolbar = [[UIToolbar alloc] init];
  _toolbar.barStyle = UIBarStyleBlackTranslucent;
  [self.view addSubview:_toolbar];    
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  NSString* delegate = [[TTNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
  [state setObject:self.textEditor.text forKey:@"text"];

  return [super persistView:state];
}

- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  NSString* delegate = [state objectForKey:@"delegate"];
  if (delegate) {
    _delegate = [[TTNavigator navigator] objectForPath:delegate];
  }
  _defaultText = [[state objectForKey:@"text"] retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self retain];
  [[TTNavigator navigator].window addSubview:self.view];

  if (_defaultText) {
    _textEditor.text = _defaultText;
    TT_RELEASE_SAFELY(_defaultText);
  } else {
    _defaultText = [_textEditor.text retain];
  }
  
  [self ensureToolbarItems];
  [_toolbar sizeToFit];
  _screenView.frame = self.view.bounds;
  _originView.hidden = YES;
  _textEditor.alpha = 1;
      
  if (animated) {
    _screenView.alpha = 0;
    _toolbar.hidden = YES;
    _textEditor.textView.hidden = YES;

    if (_originRect.size.width) {
      _textEditor.frame = CGRectOffset(_originRect, 0, -TT_STATUS_HEIGHT);
    } else {
      [self layoutTextEditor];
      _textEditor.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];

   _screenView.alpha = 0.6;
    
    if (_originRect.size.width) {
      [UIView setAnimationDidStopSelector:@selector(springInAnimationStep2)];
      
      _textEditor.frame = CGRectMake(self.view.width - (_textEditor.width + kMarginX),
                                    kMarginY, _textEditor.width, _textEditor.height*2);
    } else {
      _textEditor.transform = CGAffineTransformIdentity;
    }

    [UIView commitAnimations];
  } else {
    _screenView.alpha = 0.6;
    _textEditor.transform = CGAffineTransformIdentity;
    [self layoutTextEditor];
  }
  
  [self showStatusBar];
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
    [self dismissPopupViewControllerAnimated:YES];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTTextEditor*)textEditor {
  self.view;
  return _textEditor;
}

- (UIToolbar*)toolbar {
  if (!_toolbar) {
    self.view;
  }
  return _toolbar;
}

- (void)setOriginView:(UIView*)view {
  if (view != _originView) {
    [_originView release];
    _originView = [view retain];
    if (_originView) {
      _originRect = _originView.screenFrame;
    } else {
      _originRect = CGRectZero;
    }
  }
}

- (void)post {
  if (_textEditor.text.isEmptyOrWhitespace) {
    [self cancel];
  } else {
    BOOL shouldDismiss = [self willPostText:_textEditor.text];
    if (!shouldDismiss) {
      if ([_delegate respondsToSelector:@selector(postController:willPostText:)]) {
        shouldDismiss = [_delegate postController:self willPostText:_textEditor.text];
      }
    }
    
    if (shouldDismiss) {
      [self dismissWithResult:nil animated:YES];
    } else {
      [self enableButtons:NO];
      [self showActivity:[self titleForActivity]];
    }
  }
}

- (void)cancel {
  if (!_textEditor.text.isEmptyOrWhitespace
      && !(_defaultText && [_defaultText isEqualToString:_textEditor.text])) {
    UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
      NSLocalizedString(@"Are you sure?", @"")
      message:NSLocalizedString(@"Are you sure you want to cancel?", @"")
      delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", @"")
      otherButtonTitles:NSLocalizedString(@"No", @""), nil] autorelease];
    [cancelAlertView show];
  } else {
    [self dismissPopupViewControllerAnimated:YES];
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

    _originView.hidden = NO;
    _activityView.hidden = YES;
    _textEditor.textView.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop)];
    
    if (_originRect.size.width) {
      _textEditor.frame = CGRectOffset(_originRect, 0, -TT_STATUS_HEIGHT);
    } else {
      _textEditor.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }

    _textEditor.alpha = 0.5;
    _screenView.alpha = 0;
    _toolbar.frame = CGRectMake(0, self.view.height, self.view.width, _toolbar.height);
    
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
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
      message:title delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"")
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
