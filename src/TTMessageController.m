#import "Three20/TTMessageController.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTPickerTextField.h"
#import "Three20/TTTextEditor.h"
#import "Three20/TTActivityLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTComposeInnerScrollView : UIScrollView {
}
@end

@implementation TTComposeInnerScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if ([self pointInside:point withEvent:event]) {
    return self;
  } else {
    return nil;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageField

@synthesize title = _title, required = _required;

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
  [_title release];
  [super dealloc];
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

- (NSString*)description {
  return [NSString stringWithFormat:@"%@ %@", _title, _recipients];
}

- (void)dealloc {
  [_recipients release];
  [super dealloc];
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
  [_text release];
  [super dealloc];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageSubjectField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTMessageController

@synthesize delegate = _delegate, dataSource = _dataSource, fields = _fields;

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
    _statusView = nil;
    
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
  [_dataSource release];
  [_fields release];
  [_initialRecipients release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)send {
  self.navigationItem.rightBarButtonItem.enabled = NO;
  
  if ([_delegate respondsToSelector:@selector(composeController:didSendFields:)]) {
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
    
    [self invalidateViewState:TTViewLoading];
    [_delegate composeController:self didSendFields:fields];
  }
}

- (void)dismiss {
  if ([_delegate respondsToSelector:@selector(composeControllerDidCancel:)]) {
    [_delegate composeControllerDidCancel:self];
  }
}

- (void)cancel {
  if (_textEditor.text.length && self.viewState == TTViewDataLoaded) {
    UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
      TTLocalizedString(@"Are you sure?", @"")
      message:TTLocalizedString(@"Are you sure you want to cancel?", @"")
      delegate:self
      cancelButtonTitle:TTLocalizedString(@"Yes", @"")
      otherButtonTitles:TTLocalizedString(@"No", @""), nil] autorelease];
    [cancelAlertView show];
  } else {
    [self dismiss];
  }
}

- (void)createFieldViews {
  for (UIView* view in _fieldViews) {
    [view removeFromSuperview];
  }
  
  [_textEditor removeFromSuperview];
  
  [_fieldViews release];
  _fieldViews = [[NSMutableArray alloc] init];

  for (TTMessageField* field in _fields) {
    TTPickerTextField* textField = nil;
    if ([field isKindOfClass:[TTMessageRecipientField class]]) {
      textField = [[[TTPickerTextField alloc] initWithFrame:CGRectZero] autorelease];
      textField.dataSource = _dataSource;
      textField.autocorrectionType = UITextAutocorrectionTypeNo;
      textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      textField.rightViewMode = UITextFieldViewModeAlways;

      if ([_delegate respondsToSelector:@selector(composeControllerShowRecipientPicker:)]) {
        UIButton* addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addButton addTarget:self action:@selector(showRecipientPicker)
          forControlEvents:UIControlEventTouchUpInside];
        textField.rightView = addButton;
      }
    } else if ([field isKindOfClass:[TTMessageTextField class]]) {
      textField = [[[TTPickerTextField alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    if (textField) {
      textField.delegate = self;
      textField.backgroundColor = TTSTYLEVAR(backgroundColor);
      textField.font = TTSTYLEVAR(messageFont);
      textField.returnKeyType = UIReturnKeyNext;
      [textField sizeToFit];
      
      UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
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

- (void)updateSendCommand {
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
        if (!textField.text.isEmptyOrWhitespace) {
          compliant = NO;
        }
      }
    }
  }

  _navigationBar.topItem.rightBarButtonItem.enabled = compliant && _textEditor.text.length;
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
    _navigationBar.topItem.title = subjectField.text;
  }
  [self updateSendCommand];
}

- (void)showRecipientPicker {
  if ([_delegate respondsToSelector:@selector(composeControllerShowRecipientPicker:)]) {
    [_delegate composeControllerShowRecipientPicker:self];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {  
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  self.view = [[[UIView alloc] initWithFrame:appFrame] autorelease];
  self.view.backgroundColor = TTSTYLEVAR(backgroundColor);
  
  _navigationBar = [[UINavigationBar alloc] initWithFrame:
    CGRectMake(0, 0, appFrame.size.width, TOOLBAR_HEIGHT)];
  _navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
  [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
  [self.view addSubview:_navigationBar];

  CGRect innerFrame = CGRectMake(0, TOOLBAR_HEIGHT,
    appFrame.size.width, appFrame.size.height - (TOOLBAR_HEIGHT+KEYBOARD_HEIGHT));
  if (TTOSVersionIsAtLeast(3.0)) {
    _scrollView = [[[UIScrollView class] alloc] initWithFrame:innerFrame];
  } else {
    _scrollView = [[[TTComposeInnerScrollView class] alloc] initWithFrame:innerFrame];
  }
  _scrollView.backgroundColor = TTSTYLEVAR(backgroundColor);
  _scrollView.canCancelContentTouches = NO;
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;
  [self.view addSubview:_scrollView];

  _textEditor = [[TTTextEditor alloc] initWithFrame:CGRectMake(0, 0, appFrame.size.width, 0)];
  _textEditor.textDelegate = self;
  _textEditor.backgroundColor = TTSTYLEVAR(backgroundColor);
  _textEditor.textView.font = TTSTYLEVAR(messageFont);
  _textEditor.autoresizesToText = YES;
  _textEditor.showsExtraLine = YES;
  _textEditor.minNumberOfLines = 5;
  [_textEditor sizeToFit];
  
  [self createFieldViews];
  [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  UIView* firstTextField = [_fieldViews objectAtIndex:0];
  [firstTextField becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [super showObject:object inView:viewType withState:state];
  
  if (object) {
    _initialRecipients = [[NSArray alloc] initWithObjects:object,nil];
  }
}

- (void)updateView {
  if (_initialRecipients) {
    for (id recipient in _initialRecipients) {
      [self addRecipient:recipient forFieldAtIndex:0];
    }
    [_initialRecipients release];
    _initialRecipients = nil;
  }
}

- (void)updateLoadingView {
  if (self.viewState & TTViewLoading) {
    CGRect frame = CGRectMake(0, _navigationBar.bottom, self.view.width, _scrollView.height);
    TTActivityLabel* label = [[[TTActivityLabel alloc] initWithFrame:frame
      style:TTActivityLabelStyleWhiteBox] autorelease];
    label.text = TTLocalizedString(@"Sending...", @"");
    label.centeredToScreen = NO;
    [self.view addSubview:label];

    [_statusView release];
    _statusView = [label retain];
  } else {
    [_statusView removeFromSuperview];
    [_statusView release];
    _statusView = nil;
  }
}

- (void)unloadView {
  [super unloadView];
  [_navigationBar release];
  [_scrollView release];
  [_fieldViews release];
  [_textEditor release];
  [_statusView release];
  _navigationBar = nil;
  _scrollView = nil;
  _fieldViews = nil;
  _textEditor = nil;
  _statusView = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
  replacementString:(NSString *)string {
  if (textField == self.subjectField) {
    [NSTimer scheduledTimerWithTimeInterval:0 target:self
      selector:@selector(setTitleToSubject) userInfo:nil repeats:NO];
  }
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSUInteger fieldIndex = [_fieldViews indexOfObject:textField];
  UIView* nextView = fieldIndex == _fieldViews.count-1
    ? _textEditor.textView
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

- (void)textViewDidChange:(UITextView *)textView {
  [self updateSendCommand];
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
    [self dismiss];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)subject {
  self.view;
  for (int i = 0; i < _fields.count; ++i) {
    id field = [_fields objectAtIndex:i];
    if ([field isKindOfClass:[TTMessageSubjectField class]]) {
      TTPickerTextField* textField = [_fieldViews objectAtIndex:i];
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
      TTPickerTextField* textField = [_fieldViews objectAtIndex:i];
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

- (void)setText:(NSString*)text forFieldAtIndex:(NSUInteger)fieldIndex {
  self.view;
  TTPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
  if ([textField isKindOfClass:[TTPickerTextField class]]) {
    textField.text = text;
  }
}

@end
