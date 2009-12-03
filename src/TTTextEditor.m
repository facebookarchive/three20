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

#import "Three20/TTTextEditor.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPaddingX = 8;
static CGFloat kPaddingY = 9;

// XXXjoe This number is very sensitive - it is specifically calculated for precise word wrapping
// with 15pt normal helvetica.  If you change this number at all, UITextView may wrap the text
// before or after the TTTextEditor expands or contracts its height to match.  Obviously,
// hard-coding this value here sucks, and I need to implement a solution that works for any font.
static CGFloat kTextViewInset = 31;

static const CGFloat kUITextViewVerticalPadding = 6;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTextView : UITextView {
  BOOL _autoresizesToText;
  BOOL _overflowed;
}

@property(nonatomic) BOOL autoresizesToText;
@property(nonatomic) BOOL overflowed;

@end

@implementation TTTextView

@synthesize autoresizesToText = _autoresizesToText, overflowed = _overflowed;

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
  if (_autoresizesToText) {
    if (!_overflowed) {
      // In autosizing mode, we don't ever allow the text view to scroll past zero
      // unless it has past its maximum number of lines
      [super setContentOffset:CGPointZero animated:animated];
    } else {
      // If there is an overflow, we force the text view to keep the cursor at the bottom of the
      // view.
      [super setContentOffset: CGPointMake(offset.x, self.contentSize.height - self.height)
                     animated: animated];
    }
  } else {
    [super setContentOffset:offset animated:animated];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTextEditorInternal : NSObject <UITextViewDelegate, UITextFieldDelegate> {
  TTTextEditor* _textEditor;
  id<TTTextEditorDelegate> _delegate;
  BOOL _ignoreBeginAndEnd;
}

@property(nonatomic,assign) id<TTTextEditorDelegate> delegate;
@property(nonatomic) BOOL ignoreBeginAndEnd;

- (id)initWithTextEditor:(TTTextEditor*)textEditor;

@end

@implementation TTTextEditorInternal

@synthesize delegate = _delegate, ignoreBeginAndEnd = _ignoreBeginAndEnd;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTextEditor:(TTTextEditor*)textEditor {
  if (self = [super init]) {
    _textEditor = textEditor;
    _delegate = nil;
    _ignoreBeginAndEnd = NO;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd
      && [_delegate respondsToSelector:@selector(textEditorShouldBeginEditing:)]) {
    return [_delegate textEditorShouldBeginEditing:_textEditor];
  } else {
    return YES;
  }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd
      && [_delegate respondsToSelector:@selector(textEditorShouldEndEditing:)]) {
    return [_delegate textEditorShouldEndEditing:_textEditor];
  } else {
    return YES;
  }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didBeginEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidBeginEditing:)]) {
      [_delegate textEditorDidBeginEditing:_textEditor];
    }
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didEndEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidEndEditing:)]) {
      [_delegate textEditorDidEndEditing:_textEditor];
    }
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
    replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    if ([_delegate respondsToSelector:@selector(textEditorShouldReturn:)]) {
      if (![_delegate performSelector:@selector(textEditorShouldReturn:) withObject:_textEditor]) {
        return NO;
      }
    }
  }

  if ([_delegate respondsToSelector:@selector(textEditor:shouldChangeTextInRange:replacementText:)]) {
    return [_delegate textEditor:_textEditor shouldChangeTextInRange:range replacementText:text];
  } else {
    return YES;
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  [_textEditor performSelector:@selector(didChangeText:) withObject:NO];

  if ([_delegate respondsToSelector:@selector(textEditorDidChange:)]) {
    [_delegate textEditorDidChange:_textEditor];
  }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd && [_delegate respondsToSelector:@selector(textEditorShouldBeginEditing:)]) {
    return [_delegate textEditorShouldBeginEditing:_textEditor];
  } else {
    return YES;
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd && [_delegate respondsToSelector:@selector(textEditorShouldEndEditing:)]) {
    return [_delegate textEditorShouldEndEditing:_textEditor];
  } else {
    return YES;
  }
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didBeginEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidBeginEditing:)]) {
      [_delegate textEditorDidBeginEditing:_textEditor];
    }
  }
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
  if (!_ignoreBeginAndEnd) {
    [_textEditor performSelector:@selector(didEndEditing)];

    if ([_delegate respondsToSelector:@selector(textEditorDidEndEditing:)]) {
      [_delegate textEditorDidEndEditing:_textEditor];
    }
  }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range
        replacementString:(NSString*)string {
  BOOL shouldChange = YES;
  if ([_delegate respondsToSelector:@selector(textEditor:shouldChangeTextInRange:replacementText:)]) {
    shouldChange = [_delegate textEditor:_textEditor shouldChangeTextInRange:range
                              replacementText:string];
  }
  if (shouldChange) {
    [self performSelector:@selector(textViewDidChange:) withObject:nil afterDelay:0];
  }
  return shouldChange;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([_delegate respondsToSelector:@selector(textEditorShouldReturn:)]) {
    if (![_delegate performSelector:@selector(textEditorShouldReturn:) withObject:_textEditor]) {
      return NO;
    }
  }
  
  [_textEditor performSelector:@selector(didChangeText:) withObject:(id)YES];

  if ([_delegate respondsToSelector:@selector(textEditorDidChange:)]) {
    [_delegate textEditorDidChange:_textEditor];
  }
  return YES;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextEditor

@synthesize delegate = _delegate, minNumberOfLines = _minNumberOfLines,
  maxNumberOfLines = _maxNumberOfLines, editing = _editing,
  autoresizesToText = _autoresizesToText, showsExtraLine= _showsExtraLine;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIResponder*)activeTextField {
  if (_textView && !_textView.hidden) {
    return _textView;
  } else {
    return _textField;
  }
}

- (void)createTextView {
  if (!_textView) {
    _textView = [[TTTextView alloc] init];
    _textView.delegate = _internal;
    _textView.editable = YES;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.scrollsToTop = NO;
    _textView.showsHorizontalScrollIndicator = NO;
    // UITextViews have extra padding on the top and bottom that we don't want, so we force
    // the content to take up slightly more space. This allows us to mimic the padding of the
    // UITextLabel control.
    _textView.contentInset = UIEdgeInsetsMake(
      -kUITextViewVerticalPadding, 0,
      -kUITextViewVerticalPadding, 0);
    _textView.font = _textField.font;
    _textView.autoresizesToText = _autoresizesToText;
    _textView.textColor = _textField.textColor;
    _textView.autocapitalizationType = _textField.autocapitalizationType;
    _textView.autocorrectionType = _textField.autocorrectionType;
    _textView.enablesReturnKeyAutomatically = _textField.enablesReturnKeyAutomatically;
    _textView.keyboardAppearance = _textField.keyboardAppearance;
    _textView.keyboardType = _textField.keyboardType;
    _textView.returnKeyType = _textField.returnKeyType;
    _textView.secureTextEntry = _textField.secureTextEntry;
    [self addSubview:_textView];
  }
}

- (CGFloat)heightThatFits:(BOOL*)overflowed numberOfLines:(NSInteger*)numberOfLines {
  CGFloat lineHeight = self.font.lineHeight;
  CGFloat minHeight = _minNumberOfLines * lineHeight;
  CGFloat maxHeight = _maxNumberOfLines * lineHeight;
  CGFloat maxWidth = self.width - kTextViewInset;
  
  NSString* text = _textField.hidden ? _textView.text : _textField.text;
  if (!text.length) {
    text = @"M";
  }

  CGSize textSize = [text sizeWithFont:self.font
                          constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                          lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat newHeight = textSize.height;
  if ([text characterAtIndex:text.length-1] == 10) {
    newHeight += lineHeight;
  }
  if (_showsExtraLine) {
    newHeight += lineHeight;
  }

  if (overflowed) {
    *overflowed = maxHeight && newHeight > maxHeight;
  }

  if (numberOfLines) {
    *numberOfLines = floor(newHeight / lineHeight);
  }
  
  if (newHeight < minHeight) {
    newHeight = minHeight;
  }
  if (maxHeight && newHeight > maxHeight) {
    newHeight = maxHeight;
  }
  
  return newHeight + kPaddingY*2;
}

- (void)stopIgnoringBeginAndEnd {
  _internal.ignoreBeginAndEnd = NO;
}

- (void)constrainToText {
  NSInteger numberOfLines = 0;
  CGFloat oldHeight = self.height;
  CGFloat newHeight = [self heightThatFits:&_overflowed numberOfLines:&numberOfLines];
  CGFloat diff = newHeight - oldHeight;
    
  if (numberOfLines > 1 && !_textField.hidden) {
    [self createTextView];
    _textField.hidden = YES;
    _textView.hidden = NO;
    _textView.text = _textField.text;
    _internal.ignoreBeginAndEnd = YES;
    [_textView becomeFirstResponder];
    [self performSelector:@selector(stopIgnoringBeginAndEnd) withObject:nil afterDelay:0];
  } else if (numberOfLines == 1 && _textField.hidden) {
    _textField.hidden = NO;
    _textView.hidden = YES;
    _textField.text = _textView.text;
    _internal.ignoreBeginAndEnd = YES;
    [_textField becomeFirstResponder];
    [self performSelector:@selector(stopIgnoringBeginAndEnd) withObject:nil afterDelay:0];
  }
  
  _textView.overflowed = _overflowed;
  _textView.scrollEnabled = _overflowed;
  
  if (oldHeight && diff) {
    if ([_delegate respondsToSelector:@selector(textEditor:shouldResizeBy:)]) {
      if (![_delegate textEditor:self shouldResizeBy:diff]) {
        return;
      }
    }
    
    self.frame = TTRectContract(self.frame, 0, -diff);
  }
}

- (void)didBeginEditing {
  _editing = YES;
}

- (void)didEndEditing {
  _editing = NO;
}

- (void)didChangeText:(BOOL)insertReturn {
  if (insertReturn) {
    [self createTextView];
    _textField.hidden = YES;
    _textView.hidden = NO;
    _textView.text = [_textField.text stringByAppendingString:@"\n"];
    _internal.ignoreBeginAndEnd = YES;
    [_textView becomeFirstResponder];
    [self performSelector:@selector(stopIgnoringBeginAndEnd) withObject:nil afterDelay:0];
  }
  if (_autoresizesToText) {
    [self constrainToText];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _internal = [[TTTextEditorInternal alloc] initWithTextEditor:self];
    _textView = nil;
    _autoresizesToText = YES;
    _showsExtraLine = NO;
    _minNumberOfLines = 0;
    _maxNumberOfLines = 0;
    _editing = NO;
    _overflowed = NO;

    _textField = [[UITextField alloc] init];
    _textField.delegate = _internal;
    [self addSubview:_textField];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_internal);
  TT_RELEASE_SAFELY(_textField);
  TT_RELEASE_SAFELY(_textView);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (BOOL)becomeFirstResponder {
  return [[self activeTextField] becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
  return [[self activeTextField] resignFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  CGRect frame = CGRectMake(0, 2, self.width-kPaddingX*2, self.height);
  _textView.frame = CGRectOffset(TTRectContract(frame, 0, 14), 0, 7);
  _textField.frame = CGRectOffset(TTRectContract(frame, 9, 14), 9, 7);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat height = [self heightThatFits:nil numberOfLines:nil];
  return CGSizeMake(size.width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextInputTraits

- (UITextAutocapitalizationType)autocapitalizationType {
  return _textField.autocapitalizationType;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType {
  _textField.autocapitalizationType = autocapitalizationType;
}

- (UITextAutocorrectionType)autocorrectionType {
  return _textField.autocorrectionType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType {
  _textField.autocorrectionType = autocorrectionType;
}

- (BOOL)enablesReturnKeyAutomatically {
  return _textField.enablesReturnKeyAutomatically;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically {
  _textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (UIKeyboardAppearance)keyboardAppearance {
  return _textField.keyboardAppearance;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
  _textField.keyboardAppearance = keyboardAppearance;
}

- (UIKeyboardType)keyboardType {
  return _textField.keyboardType;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
  _textField.keyboardType = keyboardType;
}

- (UIReturnKeyType)returnKeyType {
  return _textField.returnKeyType;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
  _textField.returnKeyType = returnKeyType;
}

- (BOOL)secureTextEntry {
  return _textField.secureTextEntry;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry {
  _textField.secureTextEntry = secureTextEntry;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setDelegate:(id<TTTextEditorDelegate>)delegate {
  _delegate = delegate;
  _internal.delegate = delegate;
}

- (NSString*)text {
  if (_textView && !_textView.hidden) {
    return _textView.text;
  } else {
    return _textField.text;
  }
}

- (void)setText:(NSString*)text {
  _textField.text = _textView.text = text;
  if (_autoresizesToText) {
    [self constrainToText];
  }
}

- (NSString*)placeholder {
  return _textField.placeholder;
}

- (void)setPlaceholder:(NSString*)placeholder {
  _textField.placeholder = placeholder;
}

- (void)setAutoresizesToText:(BOOL)autoresizesToText {
  _autoresizesToText = autoresizesToText;
  _textView.autoresizesToText = _autoresizesToText;
}

- (UIFont*)font {
  return _textField.font;
}

- (void)setFont:(UIFont*)font {
  _textField.font = font;
}

- (UIColor*)textColor {
  return _textField.textColor;
}

- (void)setTextColor:(UIColor*)textColor {
  _textField.textColor = textColor;
}

- (void)scrollContainerToCursor:(UIScrollView*)scrollView {
  if (_textView.hasText) {
    if (scrollView.contentSize.height > scrollView.height) {
      NSRange range = _textView.selectedRange;
      if (range.location == _textView.text.length) {
        [scrollView scrollRectToVisible:CGRectMake(0,scrollView.contentSize.height-1,1,1)
          animated:NO];
      }
    } else {
      [scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
    }
  }
}

@end
