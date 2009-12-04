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

#import "Three20/TTMessageController.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTPickerTextField.h"
#import "Three20/TTTextEditor.h"
#import "Three20/TTActivityLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageField

@synthesize title = _title, required = _required;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title required:(BOOL)required {
  if (self = [self init]) {
    _title = [title copy];
    _required = required;
  }
  return self;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@", _title];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_title);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTPickerTextField*)createViewForController:(TTMessageController*)controller {
  return nil;
}

- (id)persistField:(UITextField*)textField {
  return nil;
}

- (void)restoreField:(UITextField*)textField withData:(id)data {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageRecipientField

@synthesize recipients = _recipients;

- (id)init {
  if (self = [super init]) {
    _recipients = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_recipients);
  [super dealloc];
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@ %@", _title, _recipients];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTMessageField

- (UITextField*)createViewForController:(TTMessageController*)controller {
  TTPickerTextField* textField = [[[TTPickerTextField alloc] init] autorelease];
  textField.dataSource = controller.dataSource;
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  textField.rightViewMode = UITextFieldViewModeAlways;

  if (controller.showsRecipientPicker) {
    UIButton* addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton addTarget:controller action:@selector(showRecipientPicker)
      forControlEvents:UIControlEventTouchUpInside];
    textField.rightView = addButton;
  }
  return textField;
}

- (id)persistField:(UITextField*)textField {
  if ([textField isKindOfClass:[TTPickerTextField class]]) {
    TTPickerTextField* picker = (TTPickerTextField*)textField;
    NSMutableArray* cellsData = [NSMutableArray array];
    for (id cell in picker.cells) {
      if ([cell conformsToProtocol:@protocol(NSCoding)]) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:cell];
        [cellsData addObject:data];
      }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:cellsData, @"cells",
                                                      textField.text, @"text", nil];
  } else {
    return [NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"text", nil];
  }
}

- (void)restoreField:(UITextField*)textField withData:(id)data {
  NSDictionary* dict = data;

  if ([textField isKindOfClass:[TTPickerTextField class]]) {
    TTPickerTextField* picker = (TTPickerTextField*)textField;
    NSArray* cellsData = [dict objectForKey:@"cells"];
    [picker removeAllCells];
    for (id cellData in cellsData) {
      id cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellData];
      [picker addCellWithObject:cell];
    }
  }
  
  textField.text = [dict objectForKey:@"text"];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageTextField

@synthesize text = _text;

- (id)init {
  if (self = [super init]) {
    _text = nil;
  }
  return self;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"%@ %@", _title, _text];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_text);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTMessageField

- (UITextField*)createViewForController:(TTMessageController*)controller {
  return [[[TTPickerTextField alloc] init] autorelease];
}

- (id)persistField:(UITextField*)textField {
  return textField.text;
}

- (void)restoreField:(UITextField*)textField withData:(id)data {
  textField.text = data;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageSubjectField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageController

@synthesize delegate = _delegate, dataSource = _dataSource, fields = _fields,
            isModified = _isModified, showsRecipientPicker = _showsRecipientPicker;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)cancel {
  [self cancel:YES];
}

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

- (void)layoutViews {
  CGFloat y = 0;
  
  for (UIView* view in _scrollView.subviews) {
    view.frame = CGRectMake(0, y, self.view.width, view.height);
    y += view.height;
  }
  
  _scrollView.contentSize = CGSizeMake(_scrollView.width, y);
}

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
        if (!textField.text.isEmptyOrWhitespace) {
          return YES;
        }
      }
    }
  }
  
  return _textEditor.text.length;
}

- (BOOL)hasRequiredText {
  BOOL compliant = YES;

  for (int i = 0; i < _fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    if (field.required) {
      if ([field isKindOfClass:[TTMessageRecipientField class]]) {
        TTPickerTextField* textField = [_fieldViews objectAtIndex:i];
        if (!textField.cells.count) {
          compliant = NO;
        }
      } else if ([field isKindOfClass:[TTMessageTextField class]]) {
        UITextField* textField = [_fieldViews objectAtIndex:i];
        if (textField.text.isEmptyOrWhitespace) {
          compliant = NO;
        }
      }
    }
  }
  
  return compliant && _textEditor.text.length;
}

- (void)updateSendCommand {
  self.navigationItem.rightBarButtonItem.enabled = [self hasRequiredText];
}

- (UITextField*)subjectField {
  for (int i = 0; i < _fields.count; ++i) {
    TTMessageField* field = [_fields objectAtIndex:i];
    if ([field isKindOfClass:[TTMessageSubjectField class]]) {
      return [_fieldViews objectAtIndex:i];
    }
  }
  return nil;    
}

- (void)setTitleToSubject {
  UITextField* subjectField = self.subjectField;
  if (subjectField) {
    self.navigationItem.title = subjectField.text;
  }
  [self updateSendCommand];
}

- (NSInteger)fieldIndexOfFirstResponder {
  NSInteger index = 0;
  for (UIView* view in _fieldViews) {
    if ([view isFirstResponder]) {
      return index;
    }
    ++index;
  }
  if (_textEditor.isFirstResponder) {
    return _fieldViews.count;
  }
  return -1;
}

- (void)setFieldIndexOfFirstResponder:(NSInteger)index {
  if (index < _fieldViews.count) {
    UIView* view = [_fieldViews objectAtIndex:index];
    [view becomeFirstResponder];
  } else {
    [_textEditor becomeFirstResponder];
  }
}

- (void)showRecipientPicker {
  [self messageWillShowRecipientPicker];
  
  if ([_delegate respondsToSelector:@selector(composeControllerShowRecipientPicker:)]) {
    [_delegate composeControllerShowRecipientPicker:self];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithRecipients:(NSArray*)recipients {
  if (self = [self init]) {
    _initialRecipients = [recipients retain];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _dataSource = nil;
    _fields = [[NSArray alloc] initWithObjects:
      [[[TTMessageRecipientField alloc] initWithTitle:
        TTLocalizedString(@"To:", @"") required:YES] autorelease],
      [[[TTMessageSubjectField alloc] initWithTitle:
        TTLocalizedString(@"Subject:", @"") required:NO] autorelease],
      nil];
    _fieldViews = nil;
    _initialRecipients = nil;
    _activityView = nil;
    _showsRecipientPicker = NO;
    _isModified = NO;
    
    self.title = TTLocalizedString(@"New Message", @"");

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      TTLocalizedString(@"Cancel", @"")
      style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      TTLocalizedString(@"Send", @"")
      style:UIBarButtonItemStyleDone target:self action:@selector(send)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_dataSource);
  TT_RELEASE_SAFELY(_fields);
  TT_RELEASE_SAFELY(_initialRecipients);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

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

- (void)viewDidUnload {
  [super viewDidUnload];
  TT_RELEASE_SAFELY(_scrollView);
  TT_RELEASE_SAFELY(_fieldViews);
  TT_RELEASE_SAFELY(_textEditor);
  TT_RELEASE_SAFELY(_activityView);
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  _scrollView.height = self.view.height - TTKeyboardHeight();
  [self layoutViews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

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
// UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
  replacementString:(NSString *)string {
  if (textField == self.subjectField) {
    _isModified = YES;
    [NSTimer scheduledTimerWithTimeInterval:0 target:self
      selector:@selector(setTitleToSubject) userInfo:nil repeats:NO];
  }
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSUInteger fieldIndex = [_fieldViews indexOfObject:textField];
  UIView* nextView = fieldIndex == _fieldViews.count-1
    ? _textEditor
    : [_fieldViews objectAtIndex:fieldIndex+1];
  [nextView becomeFirstResponder];
  return NO;
}

- (void)textField:(TTPickerTextField*)textField didAddCellAtIndex:(NSInteger)index {
  [self updateSendCommand];
}

- (void)textField:(TTPickerTextField*)textField didRemoveCellAtIndex:(NSInteger)index {
  [self updateSendCommand];
}

- (void)textFieldDidResize:(TTPickerTextField*)textField {
  [self layoutViews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTextEditorDelegate

- (void)textEditorDidChange:(TTTextEditor*)textEditor {
  [self updateSendCommand];
  _isModified = YES;
}

- (BOOL)textEditor:(TTTextEditor*)textEditor shouldResizeBy:(CGFloat)height {
  _textEditor.frame = TTRectContract(_textEditor.frame, 0, -height);
  [self layoutViews];
  [_textEditor scrollContainerToCursor:_scrollView];
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self cancel:NO];
  }
}

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

- (NSString*)body {
  return _textEditor.text;
}

- (void)setBody:(NSString*)body {
  self.view;
  _textEditor.text = body;
}

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

- (void)setFields:(NSArray*)fields {
  if (fields != _fields) {
    [_fields release];
    _fields = [fields retain];
    
    if (_fieldViews) {
      [self createFieldViews];
    }
  }
}

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

- (BOOL)fieldHasValueAtIndex:(NSUInteger)fieldIndex {
  self.view;
  
  if (fieldIndex == _fieldViews.count) {
    return _textEditor.text.length > 0;
  } else {
    TTMessageField* field = [_fields objectAtIndex:fieldIndex];
    if ([field isKindOfClass:[TTMessageRecipientField class]]) {
      TTPickerTextField* pickerTextField = [_fieldViews objectAtIndex:fieldIndex];
      return !pickerTextField.text.isEmptyOrWhitespace || pickerTextField.cellViews.count > 0;
    } else {
      UITextField* textField = [_fieldViews objectAtIndex:fieldIndex];
      return !textField.text.isEmptyOrWhitespace;
    }
  }
}

- (UIView*)viewForFieldAtIndex:(NSUInteger)fieldIndex {
  self.view;
  
  if (fieldIndex == _fieldViews.count) {
    return _textEditor;
  } else {
    return [_fieldViews objectAtIndex:fieldIndex];
  }
}

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

- (void)confirmCancellation {
  UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
    TTLocalizedString(@"Cancel", @"")
    message:TTLocalizedString(@"Are you sure you want to cancel?", @"")
    delegate:self
    cancelButtonTitle:TTLocalizedString(@"Yes", @"")
    otherButtonTitles:TTLocalizedString(@"No", @""), nil] autorelease];
  [cancelAlertView show];
}

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

- (NSString*)titleForSending {
  return TTLocalizedString(@"Sending...", @"");
}

- (BOOL)messageShouldCancel {
  return ![self hasEnteredText] || !_isModified;
}

- (void)messageWillShowRecipientPicker {
}

- (void)messageWillSend:(NSArray*)fields {
}

- (void)messageDidSend {
}

@end
