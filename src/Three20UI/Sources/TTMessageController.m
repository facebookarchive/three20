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

#import "Three20UI/TTMessageController.h"

// UI
#import "Three20UI/TTMessageControllerDelegate.h"
#import "Three20UI/TTMessageRecipientField.h"
#import "Three20UI/TTMessageTextField.h"
#import "Three20UI/TTMessageSubjectField.h"
#import "Three20UI/TTActivityLabel.h"
#import "Three20UI/TTPickerTextField.h"
#import "Three20UI/TTTextEditor.h"
#import "Three20UI/TTTableViewDataSource.h"
#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"
#import "Three20Core/TTGlobalCoreRects.h"
#import "Three20Core/NSStringAdditions.h"
#import "Three20Core/TTGlobalCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTMessageController

@synthesize fields                      = _fields;
@synthesize isModified                  = _isModified;
@synthesize showsRecipientPicker        = _showsRecipientPicker;
@synthesize requireNonEmptyMessageBody  = _requireNonEmptyMessageBody;
@synthesize dataSource                  = _dataSource;
@synthesize delegate                    = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _fields = [[NSArray alloc] initWithObjects:
               [[[TTMessageRecipientField alloc] initWithTitle: TTLocalizedString(@"To:", @"")
                                                      required: YES] autorelease],
               [[[TTMessageSubjectField alloc] initWithTitle: TTLocalizedString(@"Subject:", @"")
                                                    required: NO] autorelease],
               nil];

    self.title = TTLocalizedString(@"New Message", @"");

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                              initWithTitle: TTLocalizedString(@"Cancel", @"")
                                              style: UIBarButtonItemStyleBordered
                                              target: self
                                              action: @selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithTitle: TTLocalizedString(@"Send", @"")
                                               style: UIBarButtonItemStyleDone
                                               target: self
                                               action: @selector(send)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRecipients:(NSArray*)recipients {
	self = [self initWithNibName:nil bundle:nil];
  if (self) {
    _initialRecipients = [recipients retain];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_dataSource);
  TT_RELEASE_SAFELY(_fields);
  TT_RELEASE_SAFELY(_initialRecipients);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  [self cancel:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createFieldViews {
  for (UIView* view in _fieldViews) {
    [view removeFromSuperview];
  }

  [_textEditor removeFromSuperview];

  [_fieldViews release];
  _fieldViews = [[NSMutableArray alloc] init];

  for (TTMessageField* field in _fields) {
    TTPickerTextField* textField = [field createViewForController:self];
    if (textField) {
      textField.delegate = self;
      textField.backgroundColor = TTSTYLEVAR(backgroundColor);
      textField.font = TTSTYLEVAR(messageFont);
      textField.returnKeyType = UIReturnKeyNext;
      textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      [textField sizeToFit];

      UILabel* label = [[[UILabel alloc] init] autorelease];
      label.text = field.title;
      label.font = TTSTYLEVAR(messageFont);
      label.textColor = TTSTYLEVAR(messageFieldTextColor);
      [label sizeToFit];
      label.frame = CGRectInset(label.frame, -2, 0);
      textField.leftView = label;
      textField.leftViewMode = UITextFieldViewModeAlways;

      [_scrollView addSubview:textField];
      [_fieldViews addObject:textField];

      UIView* separator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)] autorelease];
      separator.backgroundColor = TTSTYLEVAR(messageFieldSeparatorColor);
      separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      [_scrollView addSubview:separator];
    }
  }

  [_scrollView addSubview:_textEditor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutViews {
  CGFloat y = 0;

  for (UIView* view in _scrollView.subviews) {
    view.frame = CGRectMake(0, y, self.view.width, view.height);
    y += view.height;
  }

  _scrollView.contentSize = CGSizeMake(_scrollView.width, y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasEnteredText {
  for (int i = 0; i < _fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    if (field.required) {
      if ([field isKindOfClass:[TTMessageRecipientField class]]) {
        TTPickerTextField* textField = [_fieldViews objectAtIndex:i];
        if (textField.cells.count) {
          return YES;
        }

      } else if ([field isKindOfClass:[TTMessageTextField class]]) {
        UITextField* textField = [_fieldViews objectAtIndex:i];
        if (TTIsStringWithAnyText(textField.text)
            && !textField.text.isWhitespaceAndNewlines) {
          return YES;
        }
      }
    }
  }

  return _textEditor.text.length;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasRequiredText {
  if (_requireNonEmptyMessageBody && [_textEditor.text isWhitespaceAndNewlines]) {
    return NO;
  }

  for (int i = 0; i < _fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    if (field.required) {
      if ([field isKindOfClass:[TTMessageRecipientField class]]) {
        TTPickerTextField* textField = [_fieldViews objectAtIndex:i];
        if (!textField.cells.count) {
          return NO;
        }

      } else if ([field isKindOfClass:[TTMessageTextField class]]) {
        UITextField* textField = [_fieldViews objectAtIndex:i];
        if (0 == textField.text.length || textField.text.isWhitespaceAndNewlines) {
          return NO;
        }
      }
    }
  }

  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateSendCommand {
  self.navigationItem.rightBarButtonItem.enabled = [self hasRequiredText];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextField*)subjectField {
  for (int i = 0; i < _fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    if ([field isKindOfClass:[TTMessageSubjectField class]]) {
      return [_fieldViews objectAtIndex:i];
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTitleToSubject {
  UITextField* subjectField = self.subjectField;
  if (subjectField) {
    self.navigationItem.title = subjectField.text;
  }
  [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)fieldIndexOfFirstResponder {
  NSInteger fieldIndex = 0;
  for (UIView* view in _fieldViews) {
    if ([view isFirstResponder]) {
      return fieldIndex;
    }
    ++fieldIndex;
  }

  if (_textEditor.isFirstResponder) {
    return _fieldViews.count;
  }
  return -1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFieldIndexOfFirstResponder:(NSInteger)fieldIndex {
  if (fieldIndex < _fieldViews.count) {
    UIView* view = [_fieldViews objectAtIndex:fieldIndex];
    [view becomeFirstResponder];

  } else {
    [_textEditor becomeFirstResponder];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showRecipientPicker {
  [self messageWillShowRecipientPicker];

  if ([_delegate respondsToSelector:@selector(composeControllerShowRecipientPicker:)]) {
    [_delegate composeControllerShowRecipientPicker:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];
  self.view.backgroundColor = TTSTYLEVAR(backgroundColor);

  _scrollView = [[[UIScrollView class] alloc] initWithFrame:TTKeyboardNavigationFrame()];
  _scrollView.backgroundColor = TTSTYLEVAR(backgroundColor);
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  _scrollView.canCancelContentTouches = NO;
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;
  [self.view addSubview:_scrollView];

  _textEditor = [[TTTextEditor alloc] initWithFrame:CGRectMake(0, 0, _scrollView.width, 0)];
  _textEditor.delegate = self;
  _textEditor.backgroundColor = TTSTYLEVAR(backgroundColor);
  _textEditor.font = TTSTYLEVAR(messageFont);
  _textEditor.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _textEditor.autoresizesToText = YES;
  _textEditor.showsExtraLine = YES;
  _textEditor.minNumberOfLines = 6;
  [_textEditor sizeToFit];

  [self createFieldViews];
  [self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_scrollView);
  TT_RELEASE_SAFELY(_fieldViews);
  TT_RELEASE_SAFELY(_textEditor);
  TT_RELEASE_SAFELY(_activityView);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (_initialRecipients) {
    for (id recipient in _initialRecipients) {
      [self addRecipient:recipient forFieldAtIndex:0];
    }
    TT_RELEASE_SAFELY(_initialRecipients);
  }

  if (!_frozenState) {
    for (NSInteger i = 0; i < _fields.count+1; ++i) {
      if (![self fieldHasValueAtIndex:i]) {
        UIView* view = [self viewForFieldAtIndex:i];
        [view becomeFirstResponder];
        return;
      }
    }
    [[self viewForFieldAtIndex:0] becomeFirstResponder];
  }

  [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  _scrollView.height = self.view.height - TTKeyboardHeight();
  [self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UTViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  NSMutableArray* fields = [NSMutableArray array];
  for (NSInteger i = 0; i < _fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    UITextField* view = [_fieldViews objectAtIndex:i];
    id data = [field persistField:view];
    if (data) {
      [fields addObject:data];

    } else {
      [fields addObject:@""];
    }
  }
  [state setObject:fields forKey:@"fields"];

  NSString* body = self.body;
  if (body) {
    [state setObject:body forKey:@"body"];
  }

  CGFloat scrollY = _scrollView.contentOffset.y;
  [state setObject:[NSNumber numberWithFloat:scrollY] forKey:@"scrollOffsetY"];

  NSInteger firstResponder = [self fieldIndexOfFirstResponder];
  [state setObject:[NSNumber numberWithInt:firstResponder] forKey:@"firstResponder"];
  [state setObject:[NSNumber numberWithBool:YES] forKey:@"__important__"];
  return [super persistView:state];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
  self.view;
  TT_RELEASE_SAFELY(_initialRecipients);
  NSMutableArray* fields = [state objectForKey:@"fields"];
  for (NSInteger i = 0; i < fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    UITextField* view = [_fieldViews objectAtIndex:i];

    id data = [fields objectAtIndex:i];
    if (data != [NSNull null]) {
      [field restoreField:view withData:data];
    }
  }

  NSString* body = [state objectForKey:@"body"];
  if (body) {
    self.body = body;
  }

  NSNumber* scrollY = [state objectForKey:@"scrollOffsetY"];
  _scrollView.contentOffset = CGPointMake(0, scrollY.floatValue);

  NSInteger firstResponder = [[state objectForKey:@"firstResponder"] intValue];
  [self setFieldIndexOfFirstResponder:firstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
  replacementString:(NSString *)string {
  if (textField == self.subjectField) {
    _isModified = YES;
    [NSTimer scheduledTimerWithTimeInterval:0 target:self
      selector:@selector(setTitleToSubject) userInfo:nil repeats:NO];
  }
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSUInteger fieldIndex = [_fieldViews indexOfObject:textField];
  UIView* nextView = fieldIndex == _fieldViews.count-1
    ? _textEditor
    : [_fieldViews objectAtIndex:fieldIndex+1];
  [nextView becomeFirstResponder];
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)cellIndex {
  [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textField:(TTPickerTextField*)textField didRemoveCellAtIndex:(NSInteger)cellIndex {
  [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidResize:(TTPickerTextField*)textField {
  [self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTextEditorDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textEditorDidChange:(TTTextEditor*)textEditor {
  [self updateSendCommand];
  _isModified = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textEditor:(TTTextEditor*)textEditor shouldResizeBy:(CGFloat)height {
  _textEditor.frame = TTRectContract(_textEditor.frame, 0, -height);
  [self layoutViews];
  [_textEditor scrollContainerToCursor:_scrollView];
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self cancel:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subject {
  self.view;
  for (int i = 0; i < _fields.count; ++i) {
    id field = [_fields objectAtIndex:i];
    if ([field isKindOfClass:[TTMessageSubjectField class]]) {
      UITextField* textField = [_fieldViews objectAtIndex:i];
      return textField.text;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSubject:(NSString*)subject {
  self.view;
  for (int i = 0; i < _fields.count; ++i) {
    id field = [_fields objectAtIndex:i];
    if ([field isKindOfClass:[TTMessageSubjectField class]]) {
      UITextField* textField = [_fieldViews objectAtIndex:i];
      textField.text = subject;
      break;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)body {
  return _textEditor.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBody:(NSString*)body {
  self.view;
  _textEditor.text = body;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource release];
    _dataSource = [dataSource retain];

    for (UITextField* textField in _fieldViews) {
      if ([textField isKindOfClass:[TTPickerTextField class]]) {
        TTPickerTextField* menuTextField = (TTPickerTextField*)textField;
        menuTextField.dataSource = dataSource;
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFields:(NSArray*)fields {
  if (fields != _fields) {
    [_fields release];
    _fields = [fields retain];

    if (_fieldViews) {
      [self createFieldViews];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex {
  self.view;
  TTPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
  if ([textField isKindOfClass:[TTPickerTextField class]]) {
    NSString* label = [_dataSource tableView:textField.tableView labelForObject:recipient];
    if (label) {
      [textField addCellWithObject:recipient];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)textForFieldAtIndex:(NSUInteger)fieldIndex {
  self.view;

  NSString* text = nil;
  if (fieldIndex == _fieldViews.count) {
    text = _textEditor.text;

  } else {
    TTPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
    if ([textField isKindOfClass:[TTPickerTextField class]]) {
      text = textField.text;
    }
  }

  NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
  return [text stringByTrimmingCharactersInSet:whitespace];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text forFieldAtIndex:(NSUInteger)fieldIndex {
  self.view;
  if (fieldIndex == _fieldViews.count) {
    _textEditor.text = text;

  } else {
    TTPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
    if ([textField isKindOfClass:[TTPickerTextField class]]) {
      textField.text = text;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)fieldHasValueAtIndex:(NSUInteger)fieldIndex {
  self.view;

  if (fieldIndex == _fieldViews.count) {
    return _textEditor.text.length > 0;

  } else {
    TTMessageField* field = [_fields objectAtIndex:fieldIndex];
    if ([field isKindOfClass:[TTMessageRecipientField class]]) {
      TTPickerTextField* pickerTextField = [_fieldViews objectAtIndex:fieldIndex];
      return (TTIsStringWithAnyText(pickerTextField.text)
              && !pickerTextField.text.isWhitespaceAndNewlines)
              || pickerTextField.cellViews.count > 0;

    } else {
      UITextField* textField = [_fieldViews objectAtIndex:fieldIndex];
      return (TTIsStringWithAnyText(textField.text)
              && !textField.text.isWhitespaceAndNewlines);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)viewForFieldAtIndex:(NSUInteger)fieldIndex {
  self.view;

  if (fieldIndex == _fieldViews.count) {
    return _textEditor;

  } else {
    return [_fieldViews objectAtIndex:fieldIndex];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)send {
  NSMutableArray* fields = [[_fields mutableCopy] autorelease];
  for (int i = 0; i < fields.count; ++i) {
    id field = [fields objectAtIndex:i];
    if ([field isKindOfClass:[TTMessageRecipientField class]]) {
      TTPickerTextField* textField = [_fieldViews objectAtIndex:i];
      [(TTMessageRecipientField*)field setRecipients:textField.cells];

    } else if ([field isKindOfClass:[TTMessageTextField class]]) {
      UITextField* textField = [_fieldViews objectAtIndex:i];
      [(TTMessageTextField*)field setText:textField.text];
    }
  }

  TTMessageTextField* bodyField = [[[TTMessageTextField alloc] initWithTitle:nil
                                                               required:NO] autorelease];
  bodyField.text = _textEditor.text;
  [fields addObject:bodyField];

  [self showActivityView:YES];

  [self messageWillSend:fields];

  if ([_delegate respondsToSelector:@selector(composeController:didSendFields:)]) {
    [_delegate composeController:self didSendFields:fields];
  }

  [self messageDidSend];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel:(BOOL)confirmIfNecessary {
  if (confirmIfNecessary && ![self messageShouldCancel]) {
    [self confirmCancellation];

  } else {
    if ([_delegate respondsToSelector:@selector(composeControllerWillCancel:)]) {
      [_delegate composeControllerWillCancel:self];
    }

    [self dismissModalViewController];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)confirmCancellation {
  UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
    TTLocalizedString(@"Cancel", @"")
    message:TTLocalizedString(@"Are you sure you want to cancel?", @"")
    delegate:self
    cancelButtonTitle:TTLocalizedString(@"Yes", @"")
    otherButtonTitles:TTLocalizedString(@"No", @""), nil] autorelease];
  [cancelAlertView show];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivityView:(BOOL)show {
  self.navigationItem.rightBarButtonItem.enabled = !show;
  if (show) {
    if (!_activityView) {
      CGRect frame = CGRectMake(0, 0, self.view.width, _scrollView.height);
      _activityView = [[TTActivityLabel alloc] initWithFrame:frame
                                               style:TTActivityLabelStyleWhiteBox];
      _activityView.text = [self titleForSending];
      _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      [self.view addSubview:_activityView];
    }

  } else {
    [_activityView removeFromSuperview];
    TT_RELEASE_SAFELY(_activityView);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForSending {
  return TTLocalizedString(@"Sending...", @"");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)messageShouldCancel {
  return ![self hasEnteredText] || !_isModified;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)messageWillShowRecipientPicker {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)messageWillSend:(NSArray*)fields {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)messageDidSend {
}


@end
