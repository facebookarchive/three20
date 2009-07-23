#import "Three20/TTSearchTextField.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTView.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTTableView.h"
#import "Three20/TTTableItemCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kShadowHeight = 24;
static const CGFloat kDesiredTableHeight = 150;

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

- (void)dealloc {
  [super dealloc];
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
    [_delegate textFieldDidEndEditing:textField];
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
  BOOL shouldReturn = YES;
  if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
    shouldReturn = [_delegate textFieldShouldReturn:textField];
  }
  
  if (shouldReturn) {
    if (!_textField.searchesAutomatically) {
      [_textField search];
    } else {
      [_textField performSelector:@selector(doneAction)];
    }
  }
  return shouldReturn;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTSearchTextField

@synthesize dataSource = _dataSource, tableView = _tableView, rowHeight = _rowHeight,
  searchesAutomatically = _searchesAutomatically, showsDoneButton = _showsDoneButton,
  showsDarkScreen = _showsDarkScreen;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _internal = [[TTSearchTextFieldInternal alloc] initWithTextField:self];
    _dataSource = nil;
    _tableView = nil;
    _shadowView = nil;
    _screenView = nil;
    _searchTimer = nil;
    _previousNavigationItem = nil;
    _previousRightBarButtonItem = nil;
    _rowHeight = 0;
    _showsDoneButton = NO;
    _showsDarkScreen = NO;

    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchesAutomatically = YES;
    
    [self addTarget:self action:@selector(didBeginEditing)
      forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(didEndEditing)
      forControlEvents:UIControlEventEditingDidEnd];

    [super setDelegate:_internal];
  }
  return self;
}

- (void)dealloc {
  [_dataSource.model.delegates removeObject:self];
  _tableView.delegate = nil;
  TT_RELEASE_SAFELY(_dataSource);
  TT_RELEASE_SAFELY(_internal);
  TT_RELEASE_SAFELY(_tableView);
  TT_RELEASE_SAFELY(_shadowView);
  TT_RELEASE_SAFELY(_screenView);
  TT_RELEASE_SAFELY(_previousNavigationItem);
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)showDoneButton:(BOOL)show {
  UIViewController* controller = [TTNavigator navigator].visibleViewController;
  if (controller) {
    if (show) {
      _previousNavigationItem = [controller.navigationItem retain];
      _previousRightBarButtonItem = [controller.navigationItem.rightBarButtonItem retain];
      
      UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self action:@selector(doneAction)] autorelease];
      [controller.navigationItem setRightBarButtonItem:doneButton animated:YES];
    } else {
      [_previousNavigationItem setRightBarButtonItem:_previousRightBarButtonItem animated:YES];
      TT_RELEASE_SAFELY(_previousRightBarButtonItem);
      TT_RELEASE_SAFELY(_previousNavigationItem);
    }
  }
}

- (void)showDarkScreen:(BOOL)show {
  if (show && !_screenView) {
    _screenView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _screenView.backgroundColor = TTSTYLEVAR(screenBackgroundColor);
    _screenView.frame = [self rectForSearchResults:NO];
    _screenView.alpha = 0;
    [_screenView addTarget:self action:@selector(doneAction)
      forControlEvents:UIControlEventTouchUpInside];
  }
  
  if (show) {
    [self.superviewForSearchResults addSubview:_screenView];
  }
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(screenAnimationDidStop)];

  _screenView.alpha = show ? 1 : 0;
  
  [UIView commitAnimations];
}

- (NSString*)searchText {
  if (!self.hasText) {
    return @"";
  } else {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
    return [self.text stringByTrimmingCharactersInSet:whitespace];
  }
}

- (void)autoSearch {
  if (_searchesAutomatically || !self.text.length) {
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

- (BOOL)hasSearchResults {
  return (![_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]
          || [_dataSource numberOfSectionsInTableView:_tableView])
      && [_dataSource tableView:_tableView numberOfRowsInSection:0];
}

- (void)reloadTable {
  [_dataSource tableViewDidLoadModel:self.tableView];

  if ([self hasSearchResults]) {
    [self layoutIfNeeded];
    [self showSearchResults:YES];
    [self.tableView reloadData];
  } else {
    [self showSearchResults:NO];
  }
}

- (void)screenAnimationDidStop {
  if (_screenView.alpha == 0) {
    [_screenView removeFromSuperview];
  }
}

- (void)doneAction {
  [self resignFirstResponder];

  if (self.dataSource) {
    self.text = @"";
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextField

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
  if (_rowHeight) {
    return _rowHeight;
  } else {
    id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    Class cls = [_dataSource tableView:tableView cellClassForObject:object];
    return [cls tableView:_tableView rowHeightForObject:object];
  }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if ([_internal.delegate respondsToSelector:@selector(textField:didSelectObject:)]) {
    id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSeparatorStyleNone) {
      [_internal.delegate performSelector:@selector(textField:didSelectObject:) withObject:self
                          withObject:object];      
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model {
  if (!_searchesAutomatically) {
    [self reloadTable];
  }
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
  [self reloadTable];
}

- (void)modelDidChange:(id<TTModel>)model {
  [self reloadTable];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  [self reloadTable];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)didBeginEditing {
  if (_dataSource) {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    scrollView.scrollEnabled = NO;
    scrollView.scrollsToTop = NO;

    if (_showsDoneButton) {
      [self showDoneButton:YES];
    }
    if (_showsDarkScreen) {
      [self showDarkScreen:YES];
    }
    if (self.hasText && self.hasSearchResults) {
      [self showSearchResults:YES];
    }
  }
}

- (void)didEndEditing {
  if (_dataSource) {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    scrollView.scrollEnabled = YES;
    scrollView.scrollsToTop = YES;
    
    [self showSearchResults:NO];
    
    if (_showsDoneButton) {
      [self showDoneButton:NO];
    }
    if (_showsDarkScreen) {
      [self showDarkScreen:NO];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource.model.delegates removeObject:self];
    [_dataSource release];
    _dataSource = [dataSource retain];
    [_dataSource.model.delegates addObject:self];
  }
}

- (UITableView*)tableView {
  if (!_tableView) {
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = TTSTYLEVAR(searchTableBackgroundColor);
    _tableView.separatorColor = TTSTYLEVAR(searchTableSeparatorColor);
    _tableView.rowHeight = _rowHeight;
    _tableView.dataSource = _dataSource;
    _tableView.delegate = self;
    _tableView.scrollsToTop = NO;
  }
  
  return _tableView;
}

- (void)setSearchesAutomatically:(BOOL)searchesAutomatically {
  _searchesAutomatically = searchesAutomatically;
  if (searchesAutomatically) {
    self.returnKeyType = UIReturnKeyDone;
    self.enablesReturnKeyAutomatically = NO;
  } else {
    self.returnKeyType = UIReturnKeySearch;
    self.enablesReturnKeyAutomatically = YES;
  }
}

- (BOOL)hasText {
  return self.text.length;
}

- (void)search {
  if (_dataSource) {
    NSString* text = self.searchText;
    [_dataSource search:text];
  }
}

- (void)showSearchResults:(BOOL)show {
  if (show && _dataSource) {
    self.tableView;
    
    if (!_shadowView) {
      _shadowView = [[TTView alloc] init];
      _shadowView.style = TTSTYLE(searchTableShadow);
      _shadowView.backgroundColor = [UIColor clearColor];
      _shadowView.userInteractionEnabled = NO;
    }

    if (!_tableView.superview) {
      _tableView.frame = [self rectForSearchResults:YES];
      _shadowView.frame = CGRectMake(_tableView.left, _tableView.top-1,
                                     _tableView.width, kShadowHeight);
      
      UIView* superview = self.superviewForSearchResults;
      [superview addSubview:_tableView];

      if (_tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        [superview addSubview:_shadowView];
      }
    }
    
    [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:NO];
  } else {
    [_tableView removeFromSuperview];
    [_shadowView removeFromSuperview];
  }
}

- (UIView*)superviewForSearchResults {
  UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
  if (scrollView) {
    return scrollView;
  } else {
    for (UIView* view = self.superview; view; view = view.superview) {
      if (view.height > kDesiredTableHeight) {
        return view;
      }
    }
    
    return self.superview;
  }
}

- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
  UIView* superview = self.superviewForSearchResults;

  CGFloat y = 0;
  UIView* view = self;
  while (view != superview) {
    y += view.top;
    view = view.superview;
  }  
  
  CGFloat height = self.height;
  CGFloat keyboardHeight = withKeyboard ? TT_KEYBOARD_HEIGHT : 0;
  CGFloat tableHeight = self.window.height - (self.screenY + height + keyboardHeight);
    
  return CGRectMake(0, y + self.height-1, superview.frame.size.width, tableHeight+1);
}

- (BOOL)shouldUpdate:(BOOL)emptyText {
  [self delayedUpdate];
  return YES;
}

@end
