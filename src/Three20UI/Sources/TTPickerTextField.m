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

#import "Three20UI/TTPickerTextField.h"

// UI
#import "Three20UI/TTPickerTextFieldDelegate.h"
#import "Three20UI/TTTableViewDataSource.h"
#import "Three20UI/TTPickerViewCell.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20Style/UIFontAdditions.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static NSString* kEmpty = @" ";
static NSString* kSelected = @"`";

static const CGFloat kCellPaddingY    = 3.0f;
static const CGFloat kPaddingX        = 8.0f;
static const CGFloat kSpacingY        = 6.0f;
static const CGFloat kPaddingRatio    = 1.75f;
static const CGFloat kClearButtonSize = 38.0f;
static const CGFloat kMinCursorWidth  = 50.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTPickerTextField

@synthesize cellViews     = _cellViews;
@synthesize selectedCell  = _selectedCell;
@synthesize lineCount     = _lineCount;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    _cellViews = [[NSMutableArray alloc] init];
    _lineCount = 1;
    _cursorOrigin = CGPointZero;

    self.text = kEmpty;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.clearButtonMode = UITextFieldViewModeNever;
    self.returnKeyType = UIReturnKeyDone;
    self.enablesReturnKeyAutomatically = NO;

    [self addTarget:self action:@selector(textFieldDidEndEditing)
      forControlEvents:UIControlEventEditingDidEnd];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_cellViews);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)layoutCells {
  CGFloat fontHeight = self.font.ttLineHeight;
  CGFloat lineIncrement = fontHeight + kCellPaddingY*2 + kSpacingY;
  CGFloat marginY = floor(fontHeight/kPaddingRatio);
  CGFloat marginLeft = self.leftView
    ? kPaddingX + self.leftView.width + kPaddingX/2
    : kPaddingX;
  CGFloat marginRight = kPaddingX + (self.rightView ? kClearButtonSize : 0);

  _cursorOrigin.x = marginLeft;
  _cursorOrigin.y = marginY;
  _lineCount = 1;

  if (self.width) {
    for (TTPickerViewCell* cell in _cellViews) {
      [cell sizeToFit];

      CGFloat lineWidth = _cursorOrigin.x + cell.frame.size.width + marginRight;
      if (lineWidth >= self.width) {
        _cursorOrigin.x = marginLeft;
        _cursorOrigin.y += lineIncrement;
        ++_lineCount;
      }

      cell.frame = CGRectMake(_cursorOrigin.x, _cursorOrigin.y-kCellPaddingY,
        cell.width, cell.height);
      _cursorOrigin.x += cell.frame.size.width + kPaddingX;
    }

    CGFloat remainingWidth = self.width - (_cursorOrigin.x + marginRight);
    if (remainingWidth < kMinCursorWidth) {
      _cursorOrigin.x = marginLeft;
      _cursorOrigin.y += lineIncrement;
        ++_lineCount;
    }
  }

  return _cursorOrigin.y + fontHeight + marginY;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateHeight {
  CGFloat previousHeight = self.height;
  CGFloat newHeight = [self layoutCells];
  if (previousHeight && newHeight != previousHeight) {
    self.height = newHeight;
    [self setNeedsDisplay];

    if ([self.delegate respondsToSelector:@selector(textFieldDidResize:)]) {
      [(id)self.delegate textFieldDidResize:self];
    }

    [self scrollToVisibleLine:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)marginY {
  return floor(self.font.ttLineHeight/kPaddingRatio);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)topOfLine:(int)lineNumber {
  if (lineNumber == 0) {
    return 0;

  } else {
    CGFloat ttLineHeight = self.font.ttLineHeight;
    CGFloat lineSpacing = kCellPaddingY*2 + kSpacingY;
    CGFloat marginY = floor(ttLineHeight/kPaddingRatio);
    CGFloat lineTop = marginY + ttLineHeight*lineNumber + lineSpacing*lineNumber;
    return lineTop - lineSpacing;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerOfLine:(int)lineNumber {
  CGFloat lineTop = [self topOfLine:lineNumber];
  CGFloat ttLineHeight = self.font.ttLineHeight + kCellPaddingY*2 + kSpacingY;
  return lineTop + floor(ttLineHeight/2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)heightWithLines:(int)lines {
  CGFloat ttLineHeight = self.font.ttLineHeight;
  CGFloat lineSpacing = kCellPaddingY*2 + kSpacingY;
  CGFloat marginY = floor(ttLineHeight/kPaddingRatio);
  return marginY + ttLineHeight*lines + lineSpacing*(lines ? lines-1 : 0) + marginY;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectLastCell {
  self.selectedCell = [_cellViews objectAtIndex:_cellViews.count-1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)labelForObject:(id)object {
  NSString* label = nil;
  if ([_dataSource respondsToSelector:@selector(tableView:labelForObject:)]) {
    label = [_dataSource tableView:_tableView labelForObject:object];
  }
  return label ? label : [NSString stringWithFormat:@"%@", object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  if (_dataSource) {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  [self layoutIfNeeded];
  CGFloat height = [self heightWithLines:_lineCount];
  return CGSizeMake(size.width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesBegan:touches withEvent:event];

  if (_dataSource) {
    UITouch* touch = [touches anyObject];
    if (touch.view == self) {
      self.selectedCell = nil;

    } else {
      if ([touch.view isKindOfClass:[TTPickerViewCell class]]) {
        self.selectedCell = (TTPickerViewCell*)touch.view;
        [self becomeFirstResponder];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
  if (_dataSource) {
    [self updateHeight];
  }
  [super setText:text];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)textRectForBounds:(CGRect)bounds {
  if (_dataSource && [self.text isEqualToString:kSelected]) {
    // Hide the cursor while a cell is selected
    return CGRectMake(-10, 0, 0, 0);

  } else {
    CGRect frame = CGRectOffset(bounds, _cursorOrigin.x, _cursorOrigin.y);
    frame.size.width -= (_cursorOrigin.x + kPaddingX + (self.rightView ? kClearButtonSize : 0));
    return frame;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  if (self.leftView) {
    return CGRectMake(
      bounds.origin.x+kPaddingX, self.marginY,
      self.leftView.frame.size.width, self.leftView.frame.size.height);

  } else {
    return bounds;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  if (self.rightView) {
    return CGRectMake(bounds.size.width - kClearButtonSize, bounds.size.height - kClearButtonSize,
      kClearButtonSize, kClearButtonSize);

  } else {
    return bounds;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTSearchTextField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasText {
  return self.text.length && ![self.text isEqualToString:kEmpty]
         && ![self.text isEqualToString:kSelected];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSearchResults:(BOOL)show {
  [super showSearchResults:show];
  if (show) {
    [self scrollToEditingLine:YES];

  } else {
    [self scrollToVisibleLine:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
  UIView* superview = self.superviewForSearchResults;
  CGFloat y = superview.ttScreenY;
  CGFloat visibleHeight = [self heightWithLines:1];
  CGFloat keyboardHeight = withKeyboard ? TTKeyboardHeight() : 0;
  CGFloat tableHeight = TTScreenBounds().size.height - (y + visibleHeight + keyboardHeight);

  return CGRectMake(0, self.bottom-1, superview.frame.size.width, tableHeight+1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdate:(BOOL)emptyText {
  if (emptyText && !self.hasText && !self.selectedCell && self.cells.count) {
    [self selectLastCell];
    return NO;

  } else if (emptyText && self.selectedCell) {
    [self removeSelectedCell];
    [super shouldUpdate:emptyText];
    return NO;

  } else if (!emptyText && !self.hasText && self.selectedCell) {
    [self removeSelectedCell];
    [super shouldUpdate:emptyText];
    return YES;

  } else {
    return [super shouldUpdate:emptyText];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [_tableView deselectRowAtIndexPath:indexPath animated:NO];

  id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  [self addCellWithObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControlEvents


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing {
  if (_selectedCell) {
    self.selectedCell = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)cells {
  NSMutableArray* cells = [NSMutableArray array];
  for (TTPickerViewCell* cellView in _cellViews) {
    [cells addObject:cellView.object ? cellView.object : [NSNull null]];
  }
  return cells;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addCellWithObject:(id)object {
  TTPickerViewCell* cell = [[[TTPickerViewCell alloc] init] autorelease];

  NSString* label = [self labelForObject:object];

  cell.object = object;
  cell.label = label;
  cell.font = self.font;
  [_cellViews addObject:cell];
  [self addSubview:cell];

  // Reset text so the cursor moves to be at the end of the cellViews
  self.text = kEmpty;

  if ([self.delegate respondsToSelector:@selector(textField:didAddCellAtIndex:)]) {
    [(id)self.delegate textField:self didAddCellAtIndex:_cellViews.count-1];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeCellWithObject:(id)object {
  for (int i = 0; i < _cellViews.count; ++i) {
    TTPickerViewCell* cell = [_cellViews objectAtIndex:i];
    if (cell.object == object) {
      [_cellViews removeObjectAtIndex:i];
      [cell removeFromSuperview];

      if ([self.delegate respondsToSelector:@selector(textField:didRemoveCellAtIndex:)]) {
        [(id)self.delegate textField:self didRemoveCellAtIndex:i];
      }
      break;
    }
  }

  // Reset text so the cursor oves to be at the end of the cellViews
  self.text = self.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllCells {
  while (_cellViews.count) {
    TTPickerViewCell* cell = [_cellViews objectAtIndex:0];
    [cell removeFromSuperview];
    [_cellViews removeObjectAtIndex:0];
  }

  _selectedCell = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedCell:(TTPickerViewCell*)cell {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToVisibleLine:(BOOL)animated {
  if (self.editing) {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    if (scrollView) {
      [scrollView setContentOffset:CGPointMake(0, self.top) animated:animated];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToEditingLine:(BOOL)animated {
  UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
  if (scrollView) {
    CGFloat offset = _lineCount == 1 ? 0 : [self topOfLine:_lineCount-1];
    [scrollView setContentOffset:CGPointMake(0, self.top+offset) animated:animated];
  }
}


@end
