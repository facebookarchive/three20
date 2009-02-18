#import "Three20/TTTextEditor.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPaddingX = 11;
static CGFloat kPaddingY = 12;

static CGFloat kPadding = 6;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTextEditorInternal : NSObject <UITextViewDelegate> {
  TTTextEditor* _textEditor;
  id<TTTextEditorDelegate> _delegate;
}

@property(nonatomic,assign) id<TTTextEditorDelegate> delegate;

- (id)initWithTextEditor:(TTTextEditor*)textEditor;

@end

@implementation TTTextEditorInternal

@synthesize delegate = _delegate;

- (id)initWithTextEditor:(TTTextEditor*)textEditor {
  if (self = [super init]) {
    _textEditor = textEditor;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  if ([_delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
    return [_delegate textViewShouldBeginEditing:textView];
  } else {
    return YES;
  }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
  if ([_delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
    return [_delegate textViewShouldEndEditing:textView];
  } else {
    return YES;
  }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  [_textEditor performSelector:@selector(didBeginEditing)];

  if ([_delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
    [_delegate textViewDidBeginEditing:textView];
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [_textEditor performSelector:@selector(didEndEditing)];

  if ([_delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
    [_delegate textViewDidEndEditing:textView];
  }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
    replacementText:(NSString *)text {
  if (![_textEditor performSelector:@selector(shouldChangeText:inRange:) withObject:text
    withObject:(id)range.location]) {
    return NO;
  } else {
    SEL sel = @selector(textView:shouldChangeTextInRange:replacementText:);
    if ([_delegate respondsToSelector:sel]) {
      return [_delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    } else {
      return YES;
    }
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  [_textEditor performSelector:@selector(didChangeText)];

  if ([_delegate respondsToSelector:@selector(textViewDidChange:)]) {
    [_delegate textViewDidChange:textView];
  }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  if ([_delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
    [_delegate textViewDidChangeSelection:textView];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTextEditor

@synthesize delegate = _delegate, textView, placeholder = _placeholder, fixedText = _fixedText,
  font = _font, textColor = _textColor, textAlignment = _textAlignment,
  returnKeyType = _returnKeyType, minNumberOfLines = _minNumberOfLines, editing = _editing,
  multiline = _multiline, autoresizeToText = _autoresizeToText, showExtraLine= _showExtraLine;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _internal = [[TTTextEditorInternal alloc] initWithTextEditor:self];
    _placeholder = nil;
    _fixedText = nil;
    _font = [[UIFont systemFontOfSize:15] retain];
    _textColor = [[UIColor blackColor] retain];
    _textAlignment = UITextAlignmentLeft;
    _returnKeyType = UIReturnKeyDefault;
    _autoresizeToText = YES;
    _showExtraLine = NO;
    _minNumberOfLines = 0;
    _editing = NO;
    _multiline = YES;
    _textView = nil;
    _placeholderLabel = nil;
    _fixedTextLabel = nil;
  }
  return self;
}

- (void)dealloc {
  [_internal release];
  [_textView release];
  [_placeholderLabel release];
  [_placeholder release];
  [_fixedText release];
  [_font release];
  [_textColor release];
  [_placeholder release];
  [_fixedTextLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateText {
  if (!_textView) {
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(4, -2, 0, 0)];
    _textView.delegate = _internal;
    _textView.editable = YES;
    _textView.opaque = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = _textColor;
    _textView.textAlignment = _textAlignment;
    _textView.returnKeyType = _returnKeyType;
    _textView.font = _font;
    _textView.scrollsToTop = NO;
    [self addSubview:_textView];

    if (_fixedTextLabel) {
      [self bringSubviewToFront:_fixedTextLabel];
    }
  }
}

- (void)updatePlaceholder {
  if (_placeholder && !_editing && !_textView.text.length) {
    if (!_placeholderLabel) {
      _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      if (_textColor == [UIColor whiteColor]) {
        _placeholderLabel.textColor = [UIColor whiteColor];
      } else {
        _placeholderLabel.textColor = [UIColor grayColor];
      }
      _placeholderLabel.backgroundColor = [UIColor clearColor];
      [self addSubview:_placeholderLabel];
    }
    
    _placeholderLabel.font = _font;
    _placeholderLabel.textAlignment = _textAlignment;
    _placeholderLabel.text = _placeholder;
    [self bringSubviewToFront:_placeholderLabel];
    _placeholderLabel.hidden = NO;
  } else {
    _placeholderLabel.hidden = YES;
  }
}

- (void)focus {
  [self updateText];
  [_textView becomeFirstResponder];
}

- (void)constrainToBounds:(CGRect)frame {
  _textView.frame = CGRectMake(_textView.left, _textView.top,
    frame.size.width-4, (frame.size.height*3)-kPaddingY);
  
  self.frame = frame;
}

- (void)constrainToText:(BOOL)onlyIfNeeded {
  NSString* text = self.text.length ? self.text : @"M";
  CGSize textSize = [text sizeWithFont:_font
    constrainedToSize:CGSizeMake(self.frame.size.width - kPaddingX*2, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];

  CGFloat lineHeight = [@"Mg" sizeWithFont:_textView.font].height;
  CGFloat minHeight = _minNumberOfLines * lineHeight;
  CGFloat newHeight = textSize.height + kPaddingY;
  if (newHeight < minHeight) {
    newHeight = minHeight;
  }
  if (_showExtraLine) {
    newHeight += lineHeight;
  }
  
  CGRect frame = self.frame;
  CGFloat oldHeight = frame.size.height;
  frame.size.height = newHeight;

  if (!onlyIfNeeded || (oldHeight && frame.size.height != oldHeight)) {
    [self constrainToBounds:frame];
    if (frame.size.height != oldHeight) {
      CGFloat diff = frame.size.height - oldHeight;
      if ([_delegate respondsToSelector:@selector(textEditor:didResizeBy:)]) {
        [_delegate textEditor:self didResizeBy:diff];
      }
    }
  }
}

- (BOOL)shouldChangeText:(NSString*)text inRange:(NSUInteger)location {
  if (_fixedText && location < _fixedText.length) {
    return NO;
  }
  
  if (!_multiline && [text isEqualToString:@"\n"]) {
    [_textView resignFirstResponder];
    return NO;
  } else {
    return YES;
  }
}

- (void)didChangeText {
  if (_autoresizeToText) {
    [self constrainToText:YES];
  }
}

- (void)didBeginEditing {
  _editing = YES;
  [self updatePlaceholder];
}

- (void)didEndEditing {
  if (_editing) {
    _editing = NO;
    [self updatePlaceholder];
  }
}

//- (void)_textViewDidChangeSelection:(UITextView *)_textView {
//  // Workaround for weird bug - if user touches and holds placeholder, keyboard appears
//  // but _textViewDidBeginEditing isn't called, so we call it here
//  if (!_editing) {
//    [self _textViewDidBeginEditing:_textView];
//  }
//}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  if (_autoresizeToText) {
    [self constrainToText:NO];
  } else {
    _textView.frame = CGRectMake(kPadding, kPadding,
      self.frame.size.width-kPadding*2, self.frame.size.height-kPadding*2);
  }
  _placeholderLabel.frame = CGRectMake(kPadding, kPadding,
    self.frame.size.width-kPadding*2, self.frame.size.height-kPadding*2);
    
  if (_fixedTextLabel) {
    [_fixedTextLabel sizeToFit];
    _fixedTextLabel.frame = CGRectMake(_textView.left+kPadding, _textView.top+kPadding,
      _fixedTextLabel.width+2, _fixedTextLabel.height+4);
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(focus) userInfo:nil
    repeats:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UITextView*)textView {
  [self updateText];
  return _textView;
}

- (void)setPlaceholder:(NSString*)placeholder {
  [_placeholder release];
  _placeholder = [placeholder copy];
  
  [self updatePlaceholder];
}

- (NSString*)text {
  return _textView.text;
}

- (void)setText:(NSString*)aText {
  [self updateText];
  if (_fixedText && aText) {
    _textView.text = [_fixedText stringByAppendingString:aText];
  } else {
    _textView.text = aText;
  }
  [self updatePlaceholder];
  [self setNeedsLayout];
}

- (void)setDelegate:(id<TTTextEditorDelegate>)delegate {
  _delegate = delegate;
  _internal.delegate = delegate;
}

- (void)setFixedText:(NSString*)aText {
  [_fixedText release];
  _fixedText = [aText copy];
  
  if (_fixedText && !_fixedTextLabel) {
    _fixedTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _fixedTextLabel.textColor = [UIColor grayColor];
    _fixedTextLabel.font = _font;
    _fixedTextLabel.contentMode = UIViewContentModeBottom;
    [self addSubview:_fixedTextLabel];
  }

  _fixedTextLabel.hidden = !_fixedText;
  _fixedTextLabel.text = _fixedText;
}

- (void)setFont:(UIFont*)font {
  [_font release];
  _font = [font retain];
  _textView.font = _font;
}

- (void)setTextColor:(UIColor*)color {
  [_textColor release];
  _textColor = [color retain];
  _textView.textColor = _textColor;
}

- (void)setTextAlignment:(UITextAlignment)alignment {
  _textAlignment = alignment;
  _textView.textAlignment = _placeholderLabel.textAlignment = alignment;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
  _returnKeyType = returnKeyType;
  _textView.returnKeyType = _returnKeyType;
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
