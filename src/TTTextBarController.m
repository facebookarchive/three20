#import "TTTextBarController.h"
#import "TTButton.h"
#import "TTNavigator.h"
#import "TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static CGFloat kMargin = 1;
static CGFloat kPadding = 5;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextBarController

@synthesize delegate = _delegate, textEditor = _textEditor, postButton = _postButton;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)showActivity:(NSString*)activityText {
}

- (void)showAnimationDidStop {
}

- (void)dismissAnimationDidStop {
}

- (void)dismissWithCancel {
  if ([_delegate respondsToSelector:@selector(textBarDidCancel:)]) {
    [_delegate textBarDidCancel:self];
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
    _textEditor = nil;
    _postButton = nil;
    _previousRightBarButtonItem = nil;

    if (query) {
      _delegate = [query objectForKey:@"delegate"];
      _defaultText = [[query objectForKey:@"text"] copy];
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
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  TTView* textBar = [[TTView alloc] init];
  textBar.style = TTSTYLE(textBar);
  [textBar addSubview:self.textEditor];  
  [textBar addSubview:self.postButton];

  [self.postButton sizeToFit];
  _postButton.frame = CGRectMake(TTScreenBounds().size.width - (_postButton.width + kPadding),
                                 kMargin+kPadding, _postButton.width, 27);

  _textEditor.frame = CGRectMake(5, kMargin,
                                 TTScreenBounds().size.width - (_postButton.width+kPadding+5), 0);
  [_textEditor sizeToFit];

  textBar.frame = CGRectMake(0, TTScreenBounds().size.height - (TTKeyboardHeight() + _textEditor.height),
                             TTScreenBounds().size.width+kMargin, _textEditor.height+kMargin*2);

  _postButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
                                 | UIViewAutoresizingFlexibleLeftMargin;
  _textEditor.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  textBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

  self.view = textBar;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_textEditor);
  TT_RELEASE_SAFELY(_postButton);
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self retain];
    
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

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  if (animated) {
    [_textEditor resignFirstResponder];
    [self performSelector:@selector(release) withObject:nil afterDelay:TT_TRANSITION_DURATION];
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
// TTTextEditorDelegate

- (void)textEditorDidBeginEditing:(TTTextEditor*)textEditor {
  _originTop = self.view.top;
  
  UIViewController* controller = [TTNavigator navigator].topViewController;
  _previousRightBarButtonItem = [controller.navigationItem.rightBarButtonItem retain];
  controller.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self action:@selector(cancel)] autorelease];

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

- (void)textEditorDidEndEditing:(TTTextEditor*)textEditor {
  if (_previousRightBarButtonItem) {
    UIViewController* controller = [TTNavigator navigator].topViewController;
    controller.navigationItem.rightBarButtonItem = _previousRightBarButtonItem;
    TT_RELEASE_SAFELY(_previousRightBarButtonItem);
  }

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

- (void)textEditorDidChange:(TTTextEditor*)textEditor {
  [_postButton setEnabled:textEditor.text.length > 0];
}

- (BOOL)textEditor:(TTTextEditor*)textEditor shouldResizeBy:(CGFloat)height {    
  CGRect frame = self.view.frame;
  frame.origin.y -= height;
  frame.size.height += height;
  self.view.frame = frame;
  
  return YES;
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
  if (!_textEditor) {
    _textEditor = [[TTTextEditor alloc] init];
    _textEditor.delegate = self;
    _textEditor.style = TTSTYLE(textBarTextField);
    _textEditor.backgroundColor = [UIColor clearColor];
    _textEditor.autoresizesToText = YES;
    _textEditor.maxNumberOfLines = 6;
    _textEditor.font = [UIFont systemFontOfSize:15];
  }
  return _textEditor;
}

- (TTButton*)postButton {
  if (!_postButton) {
    _postButton = [[TTButton buttonWithStyle:@"textBarPostButton:"
                             title:NSLocalizedString(@"Post", @"")] retain];
    [_postButton addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [_postButton setEnabled:NO];
  }
  return _postButton;
}

- (void)post {
  BOOL shouldDismiss = [self willPostText:_textEditor.text];
  if ([_delegate respondsToSelector:@selector(textBar:willPostText:)]) {
    shouldDismiss = [_delegate textBar:self willPostText:_textEditor.text];
  }
  
  if (shouldDismiss) {
    [self dismissWithResult:nil animated:YES];
  } else {
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
//    } else {
//      _screenView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
//    }
//
//    _innerView.alpha = 0;
//    _navigationBar.alpha = 0;
//    
//    [UIView commitAnimations];
//  } else {
//    [self dismissAnimationDidStop];
//  }
//  
//  [self hideKeyboard];
}

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
