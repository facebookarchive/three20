#import "Three20/TTSearchTextField.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTBackgroundView.h"
#import "Three20/TTTableFieldCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kShadowHeight = 24;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTSearchTextFieldInternal : NSObject <UITextFieldDelegate> {
  TTSearchTextField* _textField;
  id<UITextFieldDelegate> _delegate;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;

- (id)initWithTextField:(TTSearchTextField*)textField;

@end

@implementation TTSearchTextFieldInternal

@synthesize delegate = _delegate;

- (id)initWithTextField:(TTSearchTextField*)textField {
  if (self = [super init]) {
    _textField = textField;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
    return [_delegate textFieldShouldBeginEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
    [_delegate textFieldDidBeginEditing:textField];
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
    return [_delegate textFieldShouldEndEditing:textField];
  } else {
    return YES;
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
    return [_delegate textFieldDidEndEditing:textField];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
  if (![_textField shouldUpdate:!string.length]) {
    return NO;
  }

  SEL sel = @selector(textField:shouldChangeCharactersInRange:replacementString:);
  if ([_delegate respondsToSelector:sel]) {
    return [_delegate textField:textField shouldChangeCharactersInRange:range
      replacementString:string];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  [_textField shouldUpdate:YES];

  if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
    return [_delegate textFieldShouldClear:textField];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    return [_delegate textFieldShouldReturn:textField];
  } else {
    return YES;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchTextField

@synthesize searchSource = _searchSource, tableView = _tableView,
  searchesAutomatically = _searchesAutomatically, showsDoneButton = _showsDoneButton,
  showsDarkScreen = _showsDarkScreen;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _internal = [[TTSearchTextFieldInternal alloc] initWithTextField:self];
    _searchSource = nil;
    _searchTimer = nil;
    _tableView = nil;
    _shadowView = nil;
    _screenView = nil;
    _previousRightBarButtonItem = nil;
    _searchesAutomatically = YES;
    _showsDoneButton = NO;
    _showsDarkScreen = NO;

    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.returnKeyType = UIReturnKeySearch;
    self.enablesReturnKeyAutomatically = YES;
    
    [self addTarget:self action:@selector(didBeginEditing)
      forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(didEndEditing)
      forControlEvents:UIControlEventEditingDidEnd];

    [super setDelegate:_internal];
  }
  return self;
}

- (void)dealloc {
  [_searchSource release];
  [_internal release];
  [_tableView release];
  [_shadowView release];
  [_screenView release];
  [_previousRightBarButtonItem release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (CGRect)frameForScreen {
  UIView* parent = self.superview;
  CGFloat bottom = self.screenY + self.height;
  CGFloat tableHeight = self.window.height - (self.screenY + self.height);

  return CGRectMake(0, bottom-1, parent.frame.size.width, tableHeight);
}

- (CGRect)frameForResults {
  UIView* parent = self.superview;
  CGFloat bottom = self.screenY + self.height;
  CGFloat tableHeight = self.window.height - (self.screenY + self.height + KEYBOARD_HEIGHT);

  return CGRectMake(0, bottom-1, parent.frame.size.width, tableHeight);
}

- (void)showDoneButton:(BOOL)show {
  UIViewController* controller = [TTNavigationCenter defaultCenter].frontViewController;
  if (controller) {
    if (show) {
      _previousRightBarButtonItem = [controller.navigationItem.rightBarButtonItem retain];
      
      UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self action:@selector(doneAction)];
      [controller.navigationItem setRightBarButtonItem:doneButton animated:YES];
    } else {
      [controller.navigationItem setRightBarButtonItem:nil animated:YES];
      [_previousRightBarButtonItem release];
      _previousRightBarButtonItem = nil;
    }
  }
}

- (void)showDarkScreen:(BOOL)show {
  if (show && !_screenView) {
    _screenView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _screenView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    _screenView.frame = self.frameForScreen;
    _screenView.alpha = 0;
    [_screenView addTarget:self action:@selector(doneAction)
      forControlEvents:UIControlEventTouchUpInside];
  }
  
  if (show) {
    [self.window addSubview:_screenView];
  }
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(screenAnimationDidStop)];

  _screenView.alpha = show ? 1 : 0;
  
  [UIView commitAnimations];
}

- (void)showIndexView:(BOOL)show {
  UITableView* tableView = (UITableView*)[self firstParentOfClass:[UITableView class]];
  if (tableView) {
    UIView* indexView = tableView.indexView;
    if (indexView) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
      
      CGFloat offset = show ? -indexView.frame.size.width : indexView.frame.size.width;
      indexView.frame = CGRectOffset(indexView.frame, offset, 0);

      [UIView commitAnimations];
    }
  }
}

- (void)searchForText:(NSString*)text {
  if (text.length) {// && !self.selectedEntry) {
    if (!_tableView) {
      _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
      _tableView.backgroundColor = [TTAppearance appearance].searchTableBackgroundColor;
      _tableView.separatorColor = [TTAppearance appearance].searchTableSeparatorColor;
      _tableView.dataSource = _searchSource;
      _tableView.delegate = self;
    }

    if (!_shadowView) {
      _shadowView = [[TTBackgroundView alloc] initWithFrame:CGRectZero];
      _shadowView.backgroundColor = [UIColor clearColor];
      _shadowView.background = TTBackgroundInnerShadow;
      _shadowView.contentMode = UIViewContentModeRedraw;
      _shadowView.userInteractionEnabled = NO;
    }
    
    if (!_tableView.superview) {
      UIScrollView* scrollView = (UIScrollView*)[self firstParentOfClass:[UIScrollView class]];
      scrollView.scrollEnabled = NO;

      _tableView.frame = self.frameForResults;
      _shadowView.frame = CGRectMake(_tableView.x, _tableView.y, _tableView.width, kShadowHeight);
      
      [self.window addSubview:_tableView];
      [self.window addSubview:_shadowView];
    }

    //[self scrollToEditingLine:YES];
  } else {
    UIView* parent = self.superview;
    if (parent) {
      UIScrollView* scrollView = (UIScrollView*)[self firstParentOfClass:[UIScrollView class]];
      scrollView.scrollEnabled = YES;
      
      [_tableView removeFromSuperview];
      [_shadowView removeFromSuperview];
    }
    //[self scrollToVisibleLine:YES];
  }

  [_searchSource textField:self searchForText:text];
  _tableView.hidden = ![_tableView numberOfRowsInSection:0];
}

- (void)autoSearch {
  if (_searchesAutomatically) {
    [self search];
  }
}

- (void)dispatchUpdate:(NSTimer*)timer {
  _searchTimer = nil;
  [self autoSearch];
}

- (void)delayedUpdate {
  [_searchTimer invalidate];
  _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
    selector:@selector(dispatchUpdate:) userInfo:nil repeats:NO];
}

- (void)screenAnimationDidStop {
  if (_screenView.alpha == 0) {
    [_screenView removeFromSuperview];
  }
}

- (void)doneAction {
  self.text = @"";
  [self resignFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldd

- (id<UITextFieldDelegate>)delegate {
  return _internal.delegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  _internal.delegate = delegate;
}

- (void)setText:(NSString*)text {
  [super setText:text];
  [self autoSearch];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  id item = [_searchSource objectForRowAtIndexPath:indexPath];
  Class cls = [_searchSource cellClassForObject:item];
  return [cls rowHeightForItem:item tableView:_tableView];
}

- (void)tableView:(UITableView*)aTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)didBeginEditing {
  if (_showsDoneButton) {
    [self showDoneButton:YES];
  }
  if (_showsDarkScreen) {
    [self showDarkScreen:YES];
  }
  
  [self showIndexView:NO];
}

- (void)didEndEditing {
  if (_showsDoneButton) {
    [self showDoneButton:NO];
  }
  if (_showsDarkScreen) {
    [self showDarkScreen:NO];
  }

  [self showIndexView:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)empty {
  return !self.text.length;
}

- (BOOL)shouldUpdate:(BOOL)emptyText {
  [self delayedUpdate];
  return YES;
}

- (void)search {
  if (_searchSource) {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSString* text = [self.text stringByTrimmingCharactersInSet:whitespace];
    [self searchForText:!self.empty ? text : @""];
  }
}

- (void)updateResults {
  [_tableView reloadData];
}

@end
