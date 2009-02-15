#import "Three20/T3MenuTextField.h"
#import "T3MenuViewCell.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kEmpty = @" ";
static NSString* kSelected = @"`";

static CGFloat kCellPaddingY = 3;
static CGFloat kPaddingX = 8;
static CGFloat kSpacingY = 6;
static CGFloat kPaddingRatio = 1.75;
static CGFloat kClearButtonWidth = 38;
static CGFloat kMinCursorWidth = 50;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface T3MenuTextFieldInternal : NSObject <UITextFieldDelegate> {
  T3MenuTextField* _textField;
  id<UITextFieldDelegate> _delegate;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;

- (id)initWithTextField:(T3MenuTextField*)textField;

@end

@implementation T3MenuTextFieldInternal

@synthesize delegate = _delegate;

- (id)initWithTextField:(T3MenuTextField*)textField {
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
  if (![_textField performSelector:@selector(update:) withObject:string]) {
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
  [_textField performSelector:@selector(update:) withObject:@""];

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

@implementation T3MenuTextField

@synthesize cellViews = _cellViews, selectedCell = _selectedCell, lineCount = _lineCount,
  visibleLineCount = _visibleLineCount;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _internal = [[T3MenuTextFieldInternal alloc] initWithTextField:self];
    _cellViews = [[NSMutableArray alloc] init];
    _selectedCell = nil;
    _lineCount = 1;
    _visibleLineCount = NSUIntegerMax;
    _cursorOrigin = CGPointZero;
    
    [super setDelegate:_internal];
    self.text = kEmpty;
  }
  return self;
}

- (void)dealloc {
  [_cellViews release];
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (CGFloat)layoutCells {
  CGSize fontSize = [@"M" sizeWithFont:self.font];
  CGFloat lineIncrement = fontSize.height + kCellPaddingY*2 + kSpacingY;
  CGFloat marginY = (int)(fontSize.height/kPaddingRatio);
  CGFloat marginLeft = self.leftView
    ? kPaddingX + self.leftView.width + kPaddingX/2
    : kPaddingX;
  CGFloat marginRight = kPaddingX + (self.rightView ? kClearButtonWidth : 0);

  _cursorOrigin.x = marginLeft;
  _cursorOrigin.y = marginY;
  _lineCount = 1;
  
  for (T3MenuViewCell* cell in _cellViews) {
    [cell sizeToFit];

    CGFloat lineWidth = _cursorOrigin.x + cell.frame.size.width + marginRight;
    if (lineWidth >= self.width) {
      _cursorOrigin.x = marginLeft;
      _cursorOrigin.y += lineIncrement;
      ++_lineCount;
    }

    cell.frame = CGRectMake(_cursorOrigin.x, _cursorOrigin.y-kCellPaddingY, cell.width, cell.height);
    _cursorOrigin.x += cell.frame.size.width + kPaddingX;
  }

  CGFloat remainingWidth = self.width - (_cursorOrigin.x + marginRight);
  if (remainingWidth < kMinCursorWidth) {
    _cursorOrigin.x = marginLeft;
    _cursorOrigin.y += lineIncrement;
      ++_lineCount;
  }

  return _cursorOrigin.y + fontSize.height + marginY;
}

- (void)updateHeight {
  CGFloat previousHeight = self.height;
  CGFloat newHeight = [self layoutCells];
  if (previousHeight && newHeight != previousHeight) {
    self.height = newHeight;
    [self setNeedsDisplay];
    
//    if ([self.delegate respondsToSelector:@selector(menuTextFieldDidResize:)]) {
//      [self.delegate menuTextFieldDidResize:self];
//    }

    [self scrollToVisibleLine:YES];
  }
}

- (CGFloat)marginY {
  CGSize fontSize = [@"M" sizeWithFont:self.font];
  return (int)(fontSize.height/kPaddingRatio);
}

- (void)selectLastCell {
  self.selectedCell = [_cellViews objectAtIndex:_cellViews.count-1];
}

- (BOOL)update:(NSString*)string {
  if (!string.length && !self.hasText && !self.selectedCell && self.cells.count) {
    [self selectLastCell];
    return NO;
  } else if (!string.length && self.selectedCell) {
    [self removeSelectedCell];
//    [self delayedUpdate];
    return NO;
  } else {
//    [self delayedUpdate];
    return YES;
  }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  if (_searchSource) {
    [self layoutCells];
  } else {
    _cursorOrigin.x = kPaddingX;
    _cursorOrigin.y = [self marginY];
    if (self.leftView) {
      _cursorOrigin.x += self.leftView.width + kPaddingX/2;
    }
  }

  [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (_visibleLineCount == NSUIntegerMax) {
    return size;
  } else {
    [self layoutIfNeeded];
    CGFloat height = [self heightWithLines:_lineCount];
    return CGSizeMake(size.width, height);
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_searchSource) {
    UITouch* touch = [touches anyObject];
    if (touch.view == self) {
      self.selectedCell = nil;
    } else {
      if ([touch.view isKindOfClass:[T3MenuViewCell class]]) {
        self.selectedCell = (T3MenuViewCell*)touch.view;
      }
    }
  }
  [super touchesEnded:touches withEvent:event];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextField

- (id<UITextFieldDelegate>)delegate {
  return _internal.delegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  _internal.delegate = delegate;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  if (_searchSource && [self.text isEqualToString:kSelected]) {
    return CGRectMake(0, 0, 0, 0);
  } else if (_visibleLineCount == NSUIntegerMax) {
    CGFloat lineHeight = [@"M" sizeWithFont:self.font].height;
    return CGRectOffset(bounds, _cursorOrigin.x, floor(bounds.size.height/2 - lineHeight/2));
  } else {
    CGRect frame = CGRectOffset(bounds, _cursorOrigin.x, _cursorOrigin.y);
    frame.size.width -= (_cursorOrigin.x + kPaddingX + (self.rightView ? kClearButtonWidth : 0));
    return frame;
  }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  if (self.leftView) {
    return CGRectMake(
      bounds.origin.x+kPaddingX, floor(bounds.size.height/2 - self.leftView.frame.size.height/2),
      self.leftView.frame.size.width, self.leftView.frame.size.height);
  } else {
    return bounds;
  }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  if (self.rightView) {
    return CGRectMake(bounds.size.width - kClearButtonWidth, bounds.size.height - kClearButtonWidth,
      kClearButtonWidth, kClearButtonWidth);
  } else {
    return bounds;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray*)cells {
  NSMutableArray* cells = [NSMutableArray array];
  for (T3MenuViewCell* cellView in _cellViews) {
    [cells addObject:cellView.object ? cellView.object : [NSNull null]];
  }
  return cells;
}

- (BOOL)hasText {
  return self.text.length && ![self.text isEqualToString:kEmpty]
    && ![self.text isEqualToString:kSelected];
}

- (void)addCellWithObject:(id)object label:(NSString*)label {
  T3MenuViewCell* cell = [[[T3MenuViewCell alloc] initWithFrame:CGRectZero] autorelease];

  cell.object = object;
  cell.label = label;
  [_cellViews addObject:cell];
  [self addSubview:cell];  

  // Reset text so the cursor moves to be at the end of the cellViews
  self.text = kEmpty;

//  if ([self.delegate respondsToSelector:@selector(menuTextField:didAddCell:atIndex:)]) {
//    [self.delegate menuTextField:self didAddCell:cell atIndex:_cellViews.count-1];
//  }
}

- (void)removeCellWithObject:(id)object {
  for (int i = 0; i < _cellViews.count; ++i) {
    T3MenuViewCell* cell = [_cellViews objectAtIndex:i];
    if (cell.object == object) {
      [_cellViews removeObjectAtIndex:i];
      [cell removeFromSuperview];
//      if ([self.delegate respondsToSelector:@selector(menuTextField:didRemoveCell:atIndex:)]) {
//        [self.delegate menuTextField:self didRemoveCell:cell atIndex:i];
//      }
      break;
    }
  }

  // Reset text so the cursor oves to be at the end of the cellViews
  self.text = self.text;
}


- (void)removeAllCells {
  while (_cellViews.count) {
    T3MenuViewCell* cell = [_cellViews objectAtIndex:0];
    [cell removeFromSuperview];
    [_cellViews removeObjectAtIndex:0];
  }
  
  _selectedCell = nil;
}

- (void)setSelectedCell:(T3MenuViewCell*)cell {
  if (_selectedCell) {
    _selectedCell.selected = NO;
  }
  
  _selectedCell = cell;

  if (_selectedCell) {
    _selectedCell.selected = YES;
    self.text = kSelected;
  } else if (self.cells.count) {
    self.text = kEmpty;
  }
}

- (void)removeSelectedCell {
  if (_selectedCell) {
    [self removeCellWithObject:_selectedCell.object];
    _selectedCell = nil;

    if (_cellViews.count) {
      self.text = kEmpty;
    } else {
      self.text = @"";
    }
  }
}

- (CGFloat)lineTop:(int)lineNumber {
  if (lineNumber == 0) {
    return 0;
  } else {
    CGFloat lineHeight = [@"M" sizeWithFont:self.font].height;
    CGFloat lineSpacing = kCellPaddingY*2 + kSpacingY;
    CGFloat marginY = (int)(lineHeight/kPaddingRatio);
    CGFloat lineTop = marginY + lineHeight*lineNumber + lineSpacing*lineNumber;
    return lineTop - (kCellPaddingY+kSpacingY);
  }
}

- (CGFloat)lineCenter:(int)lineNumber {
  CGFloat lineTop = [self lineTop:lineNumber];
  CGFloat lineHeight = [@"M" sizeWithFont:self.font].height + kCellPaddingY*2 + kSpacingY;
  return lineTop + floor(lineHeight/2);
}

- (CGFloat)heightWithLines:(int)lines {
  CGFloat lineHeight = [@"M" sizeWithFont:self.font].height;
  CGFloat lineSpacing = kCellPaddingY*2 + kSpacingY;
  CGFloat marginY = (int)(lineHeight/kPaddingRatio);
  return marginY + lineHeight*lines + lineSpacing*(lines ? lines-1 : 0) + marginY;
}

- (void)scrollToVisibleLine:(BOOL)animated {
  if (_visibleLineCount != NSUIntegerMax && self.editing) {
    UIScrollView* scrollView = (UIScrollView*)[self firstParentOfClass:[UIScrollView class]];
    if (scrollView) {
      if (_lineCount > _visibleLineCount) {
        int topLine = _lineCount - _visibleLineCount;
        CGFloat offset = [self lineCenter:topLine-1];
        [scrollView setContentOffset:CGPointMake(0, self.y+offset) animated:animated];
      } else {
        [scrollView setContentOffset:CGPointMake(0, self.y) animated:animated];
      }
    }
  }
}

- (void)scrollToEditingLine:(BOOL)animated {
  UIScrollView* scrollView = (UIScrollView*)[self firstParentOfClass:[UIScrollView class]];
  if (scrollView) {
    CGFloat offset = _lineCount == 1 ? 0 : [self lineTop:_lineCount-1];
    [scrollView setContentOffset:CGPointMake(0, self.y+offset) animated:animated];
  }
}

@end
