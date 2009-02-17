#import "Three20/TTComposeController.h"
#import "Three20/TTObject.h"
#import "Three20/TTAppearance.h"
#import "Three20/TTMenuTextField.h"
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

@implementation TTComposerField

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

@implementation TTComposerRecipientField

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

@implementation TTComposerTextField

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

@implementation TTComposerSubjectField
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTComposeController

@synthesize delegate = _delegate, searchSource = _searchSource, fields = _fields;

- (id)initWithRecipients:(NSArray*)recipients {
  if (self = [self init]) {
    _initialRecipients = [recipients retain];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _searchSource = nil;
    _fields = [[NSArray alloc] initWithObjects:
      [[[TTComposerRecipientField alloc] initWithTitle:NSLocalizedString(@"To:", @"")
        required:YES] autorelease],
      [[[TTComposerSubjectField alloc] initWithTitle:NSLocalizedString(@"Subject:", @"")
        required:NO] autorelease],
      nil];
    _fieldViews = nil;
    _initialRecipients = nil;
    
    self.title = NSLocalizedString(@"New Message", @"");

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      NSLocalizedString(@"Cancel", @"")
      style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      NSLocalizedString(@"Send", @"")
      style:UIBarButtonItemStyleDone target:self action:@selector(send)] autorelease];
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
  return self;
}

- (void)dealloc {
  [_searchSource release];
  [_fields release];
  [_initialRecipients release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)send {
  self.navigationItem.rightBarButtonItem.enabled = NO;
  
  if ([_delegate respondsToSelector:@selector(composeController:didSendFields:)]) {
    NSMutableArray* fields = [_fields mutableCopy];
    for (int i = 0; i < fields.count; ++i) {
      id field = [fields objectAtIndex:i];
      if ([field isKindOfClass:[TTComposerRecipientField class]]) {
        TTMenuTextField* textField = [_fieldViews objectAtIndex:i];
        [(TTComposerRecipientField*)field setRecipients:textField.cells];
      } else if ([field isKindOfClass:[TTComposerTextField class]]) {
        UITextField* textField = [_fieldViews objectAtIndex:i];
        [(TTComposerTextField*)field setText:textField.text];
      }
    }
    
    TTComposerTextField* bodyField = [[[TTComposerTextField alloc] initWithTitle:nil
      required:NO] autorelease];
    bodyField.text = _textEditor.text;
    [fields addObject:bodyField];
    
    self.contentState |= TTContentActivity;
    [_delegate composeController:self didSendFields:fields];
  }
}

- (void)dismiss {
  if ([_delegate respondsToSelector:@selector(composeControllerDidCancel:)]) {
    [_delegate composeControllerDidCancel:self];
  }
}

- (void)cancel {
  if (_textEditor.text.length && self.contentState == TTContentReady) {
    UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
      NSLocalizedString(@"Are you sure?", @"")
      message:NSLocalizedString(@"Are you sure you want to cancel?", @"")
      delegate:self
      cancelButtonTitle:NSLocalizedString(@"Yes", @"")
      otherButtonTitles:NSLocalizedString(@"No", @""), nil] autorelease];
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

  for (TTComposerField* field in _fields) {
    TTMenuTextField* textField = nil;
    if ([field isKindOfClass:[TTComposerRecipientField class]]) {
      textField = [[TTMenuTextField alloc] initWithFrame:CGRectZero];
      textField.searchSource = _searchSource;
      textField.autocorrectionType = UITextAutocorrectionTypeNo;
      textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      textField.rightViewMode = UITextFieldViewModeAlways;

      if ([_delegate respondsToSelector:@selector(composeControllerShowRecipientPicker:)]) {
        UIButton* addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addButton addTarget:self action:@selector(showRecipientPicker)
          forControlEvents:UIControlEventTouchUpInside];
        textField.rightView = addButton;
      }
    } else if ([field isKindOfClass:[TTComposerTextField class]]) {
      textField = [[TTMenuTextField alloc] initWithFrame:CGRectZero];
    }
    
    if (textField) {
      textField.delegate = self;
      textField.backgroundColor = [UIColor whiteColor];
      textField.font = [UIFont systemFontOfSize:15];
      textField.returnKeyType = UIReturnKeyNext;
      [textField sizeToFit];
      
      UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
      label.text = field.title;
      label.font = [UIFont systemFontOfSize:15];
      label.textColor = [UIColor colorWithWhite:0.7 alpha:1];
      [label sizeToFit];
      label.frame = CGRectInset(label.frame, -2, 0);
      textField.leftView = label;
      textField.leftViewMode = UITextFieldViewModeAlways;

      [_scrollView addSubview:textField];
      [_fieldViews addObject:textField];

      UIView* separator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)] autorelease];
      separator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
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
    TTComposerField* field = [_fields objectAtIndex:i];
    if (field.required) {
      if ([field isKindOfClass:[TTComposerRecipientField class]]) {
        TTMenuTextField* textField = [_fieldViews objectAtIndex:i];
        if (!textField.cells.count) {
          compliant = NO;
        }
      } else if ([field isKindOfClass:[TTComposerTextField class]]) {
        UITextField* textField = [_fieldViews objectAtIndex:i];
        if (!textField.text.length) {
          compliant = NO;
        }
      }
    }
  }

  _navigationBar.topItem.rightBarButtonItem.enabled = compliant && _textEditor.text.length;
}

- (UITextField*)subjectField {
  for (int i = 0; i < _fields.count; ++i) {
    TTComposerField* field = [_fields objectAtIndex:i];
    if ([field isKindOfClass:[TTComposerSubjectField class]]) {
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
  self.view.backgroundColor = [UIColor whiteColor];
  
  _navigationBar = [[UINavigationBar alloc] initWithFrame:
    CGRectMake(0, 0, appFrame.size.width, TOOLBAR_HEIGHT)];
  _navigationBar.tintColor = [TTAppearance appearance].navigationBarTintColor;
  [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
  [self.view addSubview:_navigationBar];

  CGRect innerFrame = CGRectMake(0, TOOLBAR_HEIGHT,
    appFrame.size.width, appFrame.size.height - (TOOLBAR_HEIGHT+KEYBOARD_HEIGHT));
  _scrollView = [[TTComposeInnerScrollView alloc] initWithFrame:innerFrame];
  _scrollView.backgroundColor = [UIColor whiteColor];
  _scrollView.canCancelContentTouches = NO;
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;
  [self.view addSubview:_scrollView];

  _textEditor = [[TTTextEditor alloc] initWithFrame:CGRectMake(0, 0, appFrame.size.width, 0)];
  _textEditor.delegate = self;
  _textEditor.backgroundColor = [UIColor whiteColor];
  _textEditor.autoresizeToText = YES;
  _textEditor.textView.font = [UIFont systemFontOfSize:15];
  _textEditor.minNumberOfLines = 5;
  _textEditor.showExtraLine = YES;

  [self createFieldViews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  UIView* firstTextField = [_fieldViews objectAtIndex:0];
  [firstTextField becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (void)showObject:(id<TTObject>)object inView:(NSString*)viewType withState:(NSDictionary*)state {
  [super showObject:object inView:viewType withState:state];
  
  _initialRecipients = [[NSArray alloc] initWithObjects:object,nil];
  [self invalidate];
}

- (void)updateView {
  if (self.contentState & TTContentActivity) {
    CGRect frame = CGRectMake(0, _navigationBar.bottom,
      self.view.width, _scrollView.height);
    TTActivityLabel* label = [[[TTActivityLabel alloc] initWithFrame:frame
      style:TTActivityLabelStyleWhiteBox] autorelease];
    label.text = @"Sending...";
    label.centeredToScreen = NO;
    [self.view addSubview:label];

    [_statusView release];
    _statusView = [label retain];
  } else if (self.contentState == TTContentReady) {
    [_statusView removeFromSuperview];
    [_statusView release];
    _statusView = nil;
    
    if (_initialRecipients) {
      for (id recipient in _initialRecipients) {
        [self addRecipient:recipient forFieldAtIndex:0];
      }
      [_initialRecipients release];
      _initialRecipients = nil;
    }
  }
}

- (void)unloadView {
  [super unloadView];
  [_navigationBar release];
  [_scrollView release];
  [_fieldViews release];
  [_textEditor release];
  _navigationBar = nil;
  _scrollView = nil;
  _fieldViews = nil;
  _textEditor = nil;
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

- (void)textField:(TTMenuTextField*)textField didAddCellAtIndex:(NSInteger)index {
  [self updateSendCommand];
}

- (void)textField:(TTMenuTextField*)textField didRemoveCellAtIndex:(NSInteger)index {
  [self updateSendCommand];
}

- (void)textFieldDidResize:(TTMenuTextField*)textField {
  [self layoutViews];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTextEditorDelegate

- (void)textViewDidChange:(UITextView *)textView {
  [self updateSendCommand];
}

- (void)textEditor:(TTTextEditor*)textEditor didResizeBy:(CGFloat)height {
  [self layoutViews];
  [_textEditor scrollContainerToCursor:_scrollView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self dismiss];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSearchSource:(id<TTSearchSource>)searchSource {
  if (searchSource != _searchSource) {
    [_searchSource release];
    _searchSource = [searchSource retain];
    
    for (UITextField* textField in _fieldViews) {
      if ([textField isKindOfClass:[TTMenuTextField class]]) {
        TTMenuTextField* menuTextField = (TTMenuTextField*)textField;
        menuTextField.searchSource = searchSource;
      }
    }
  }
}

- (void)setFields:(NSArray*)fields {
  if (fields != _fields) {
    [_fields release];
    fields = [fields retain];
    
    if (_fieldViews) {
      [self createFieldViews];
    }
  }
}

- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex {
  TTMenuTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
  if ([textField isKindOfClass:[TTMenuTextField class]]) {
    NSString* label = [_searchSource textField:textField labelForObject:recipient];
    if (label) {
      [textField addCellWithObject:recipient];
    }
  }
}

@end
