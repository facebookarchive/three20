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

#import "Three20UI/TTTextBarController.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTTextBarDelegate.h"
#import "Three20UI/TTButton.h"
#import "Three20UI/TTTextEditor.h"
#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"
#import "Three20UICommon/UIView+TTUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTGlobalCoreLocale.h"
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/NSStringAdditions.h"
#import "Three20Core/TTGlobalCore.h"

static CGFloat kMargin  = 1;
static CGFloat kPadding = 5;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTextBarController

@synthesize textEditor  = _textEditor;
@synthesize postButton  = _postButton;
@synthesize footerBar   = _footerBar;

@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self initWithNibName:nil bundle:nil]) {
    if (nil != query) {
      _delegate = [query objectForKey:@"delegate"];
      _defaultText = [[query objectForKey:@"text"] copy];
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNavigatorURL:nil query:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_result);
  TT_RELEASE_SAFELY(_defaultText);
  TT_RELEASE_SAFELY(_footerBar);
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(NSString*)activityText {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showAnimationDidStop {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimationDidStop {
  [self release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissWithCancel {
  if ([_delegate respondsToSelector:@selector(textBarDidCancel:)]) {
    [_delegate textBarDidCancel:self];
  }

  [self dismissPopupViewControllerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  CGSize screenSize = TTScreenBounds().size;

  self.view = [[[UIView alloc] init] autorelease];
  _textBar = [[TTView alloc] init];
  _textBar.style = TTSTYLE(textBar);
  [self.view addSubview:_textBar];

  [_textBar addSubview:self.textEditor];
  [_textBar addSubview:self.postButton];

  [self.postButton sizeToFit];
  _postButton.frame = CGRectMake(screenSize.width - (_postButton.width + kPadding),
                                 kMargin+kPadding, _postButton.width, 0);

  _textEditor.frame = CGRectMake(kPadding, kMargin,
                                 screenSize.width - (_postButton.width+kPadding*2), 0);
  [_textEditor sizeToFit];
  _postButton.height = _textEditor.size.height - 8;

  _textBar.frame = CGRectMake(0, 0,
                              screenSize.width, _textEditor.height+kMargin*2);

  self.view.frame = CGRectMake(0, screenSize.height - (TTKeyboardHeight() + _textEditor.height),
                              screenSize.width, _textEditor.height+kMargin*2);

  if (_footerBar) {
    _footerBar.frame = CGRectMake(0, _textBar.height, screenSize.width, _footerBar.height);
    [self.view addSubview:_footerBar];
    self.view.top -= _footerBar.height;
    self.view.height += _footerBar.height;
  }

  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
                              | UIViewAutoresizingFlexibleTopMargin;
  _postButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                 | UIViewAutoresizingFlexibleLeftMargin;
  _textEditor.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  _textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _footerBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_textBar);
  TT_RELEASE_SAFELY(_textEditor);
  TT_RELEASE_SAFELY(_postButton);
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  [state setObject:[NSNumber numberWithBool:YES] forKey:@"__important__"];

  NSString* delegate = [[TTNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
  [state setObject:_textEditor.text forKey:@"text"];

  NSString* title = self.navigationItem.title;

  if (title) {
    [state setObject:title forKey:@"title"];
  }

  return [super persistView:state];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTPopupViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showInView:(UIView*)view animated:(BOOL)animated {
  self.view.transform = TTRotateTransformForOrientation(TTInterfaceOrientation());
  [view addSubview:self.view];

  if (_defaultText) {
    _textEditor.text = _defaultText;
    TT_RELEASE_SAFELY(_defaultText);

  } else {
    _defaultText = [_textEditor.text retain];
  }

  self.view.top = self.view.superview.height;

  [_textEditor becomeFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  if (animated) {
    [_textEditor resignFirstResponder];

  } else {
    UIViewController* superController = self.superController;
    [self.view removeFromSuperview];
    superController.popupViewController = nil;
    [superController viewWillAppear:animated];
    [superController viewDidAppear:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTextEditorDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textEditorDidBeginEditing:(TTTextEditor*)textEditor {
  [self retain];

  _originTop = self.view.top;

  UIViewController* controller = self.view.viewController;
  _previousRightBarButtonItem = [controller.navigationItem.rightBarButtonItem retain];
  [controller.navigationItem setRightBarButtonItem:
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self action:@selector(cancel)] autorelease] animated:YES];

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];

  CGRect rect = [self.view.superview frameWithKeyboardSubtracted:0];
  self.view.top = rect.size.height - self.view.height;

  [UIView commitAnimations];

  if ([_delegate respondsToSelector:@selector(textBarDidBeginEditing:)]) {
    [_delegate textBarDidBeginEditing:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textEditorDidEndEditing:(TTTextEditor*)textEditor {
  UIViewController* controller = self.view.viewController;
  [controller.navigationItem setRightBarButtonItem:_previousRightBarButtonItem animated:YES];
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop)];

  self.view.top = _originTop;

  [UIView commitAnimations];

  if ([_delegate respondsToSelector:@selector(textBarDidEndEditing:)]) {
    [_delegate textBarDidEndEditing:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textEditorDidChange:(TTTextEditor*)textEditor {
  [_postButton setEnabled:textEditor.text.length > 0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textEditor:(TTTextEditor*)textEditor shouldResizeBy:(CGFloat)height {
  CGRect frame = self.view.frame;
  frame.origin.y -= height;
  frame.size.height += height;
  _textBar.height += height;
  _footerBar.top += height;
  self.view.frame = frame;

  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self dismissWithCancel];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTTextEditor*)textEditor {
  if (!_textEditor) {
    _textEditor = [[TTTextEditor alloc] init];
    _textEditor.delegate = self;
    _textEditor.style = TTSTYLE(textBarTextField);
    _textEditor.backgroundColor = [UIColor clearColor];
    _textEditor.autoresizesToText = YES;
    _textEditor.maxNumberOfLines = 6;
    _textEditor.font = [UIFont systemFontOfSize:16];
  }
  return _textEditor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTButton*)postButton {
  if (!_postButton) {
    _postButton = [[TTButton buttonWithStyle:@"textBarPostButton:"
                             title:NSLocalizedString(@"Post", @"")] retain];
    [_postButton addTarget: self
                    action: @selector(post)
          forControlEvents: UIControlEventTouchUpInside];
    [_postButton setEnabled:NO];
  }
  return _postButton;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)post {
  BOOL shouldDismiss = [self willPostText:_textEditor.text];
  if ([_delegate respondsToSelector:@selector(textBar:willPostText:)]) {
    shouldDismiss = [_delegate textBar:self willPostText:_textEditor.text];
  }

  _textEditor.text = @"";
  _postButton.enabled = NO;

  if (shouldDismiss) {
    [self dismissWithResult:nil animated:YES];

  } else {
    [self showActivity:[self titleForActivity]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  if (!TTIsStringWithAnyText(_textEditor.text)
      && !_textEditor.text.isWhitespaceAndNewlines
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissWithResult:(id)result animated:(BOOL)animated {
  [_result release];
  _result = [result retain];

  [self dismissPopupViewControllerAnimated:YES];

//  if (animated) {
//    if ([_delegate respondsToSelector:@selector(textBar:willAnimateTowards:)]) {
//      CGRect rect = [_delegate textBar:self willAnimateTowards:_originRect];
//      if (!CGRectIsEmpty(rect)) {
//        _originRect = rect;
//      }
//    }
//
//    CGRect originRect = _originRect;
//    if (CGRectIsEmpty(originRect) && _originView) {
//      originRect = _originView.screenFrame;
//    }
//
//    _originView.hidden = NO;
//    _activityView.hidden = YES;
//    _textEditor.hidden = YES;
//
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop)];
//
//    if (!CGRectIsEmpty(originRect)) {
//      _screenView.frame = CGRectOffset(originRect, 0, -TTStatusHeight());
//
//    } else {
//      _screenView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
//    }
//
//    _innerView.alpha = 0;
//    _navigationBar.alpha = 0;
//
//    [UIView commitAnimations];
//
//  } else {
//    [self dismissAnimationDidStop];
//  }
//
//  [self hideKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)failWithError:(NSError*)error {
  [self showActivity:nil];

  NSString* title = [self titleForError:error];
  if (title.length) {
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:TTLocalizedString(@"Error", @"")
      message:title delegate:nil cancelButtonTitle:TTLocalizedString(@"Ok", @"")
      otherButtonTitles:nil] autorelease];
    [alertView show];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)willPostText:(NSString*)text {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForActivity {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError:(NSError*)error {
  return nil;
}


@end
