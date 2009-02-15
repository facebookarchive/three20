#import "Three20/T3SearchTextField.h"
#import "Three20/T3BackgroundView.h"
#import "Three20/T3TableFieldCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3SearchTextFieldInternal : NSObject <UITextFieldDelegate> {
  T3SearchTextField* _textField;
  id<UITextFieldDelegate> _delegate;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;

- (id)initWithTextField:(T3SearchTextField*)textField;

@end

@implementation T3SearchTextFieldInternal

@synthesize delegate = _delegate;

- (id)initWithTextField:(T3SearchTextField*)textField {
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

@implementation T3SearchTextField

@synthesize searchSource = _searchSource, tableView = _tableView,
  searchAutomatically = _searchAutomatically;;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _internal = [[T3SearchTextFieldInternal alloc] initWithTextField:self];
    _searchSource = nil;
    _searchTimer = nil;
    _tableView = nil;
    _shadowView = nil;
    _searchAutomatically = YES;
    
    [super setDelegate:_internal];
  }
  return self;
}

- (void)dealloc {
  [_searchSource release];
  [_internal release];
  [_tableView release];
  [_shadowView release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)searchForText:(NSString*)text {
  if (text.length) {// && !self.selectedEntry) {
    if (!_tableView) {
      _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
      _tableView.backgroundColor = [T3Appearance appearance].searchTableBackgroundColor;
      _tableView.separatorColor = [T3Appearance appearance].searchTableSeparatorColor;
      _tableView.dataSource = _searchSource;
      _tableView.delegate = self;
    }

    if (!_shadowView) {
      _shadowView = [[T3BackgroundView alloc] initWithFrame:CGRectZero];
      _shadowView.backgroundColor = [UIColor clearColor];
      _shadowView.background = T3BackgroundInnerShadow;
      _shadowView.contentMode = UIViewContentModeRedraw;
      _shadowView.userInteractionEnabled = NO;
    }
    
    if (!_tableView.superview) {
      UIView* parent = self.superview;
      CGFloat bottom = self.y + self.height;
      CGFloat height = 0;//[self heightWithLines:1];
      if ([parent isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scrollView = (UIScrollView*)parent;
        scrollView.scrollEnabled = NO;
      }

      _tableView.frame = CGRectMake(0, bottom, parent.frame.size.width,
        parent.frame.size.height-height+1);
      _shadowView.frame = CGRectMake(_tableView.x, _tableView.y, _tableView.width, 24);
      
      [parent addSubview:_tableView];
      [parent addSubview:_shadowView];
    }

    //[self scrollToEditingLine:YES];
  } else {
    UIView* parent = self.superview;
    if (parent) {
      if ([parent isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scrollView = (UIScrollView*)parent;
        scrollView.scrollEnabled = YES;
      }

      [_tableView removeFromSuperview];
      [_shadowView removeFromSuperview];
    }
    //[self scrollToVisibleLine:YES];
  }

  [_searchSource textField:self searchForText:text];
  _tableView.hidden = ![_tableView numberOfRowsInSection:0];
}

- (void)autoSearch {
  if (_searchAutomatically) {
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
