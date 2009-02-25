#import "Three20/TTTextEditor.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPaddingX = 8;
static CGFloat kPaddingY = 11;
static CGFloat kOffsetY = 3;

static CGFloat kTextViewInset = 19;

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

@synthesize delegate = _delegate, textView = _textView, placeholder = _placeholder,
  fixedText = _fixedText, minNumberOfLines = _minNumberOfLines,
  maxNumberOfLines = _maxNumberOfLines, editing = _editing, autoresizesToText = _autoresizesToText,
  showsExtraLine= _showsExtraLine;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _internal = [[TTTextEditorInternal alloc] initWithTextEditor:self];
    _placeholder = nil;
    _fixedText = nil;
    _autoresizesToText = YES;
    _showsExtraLine = NO;
    _minNumberOfLines = 0;
    _maxNumberOfLines = 0;
    _editing = NO;
    _overflowed = NO;
    _textView = nil;
    _placeholderLabel = nil;
    _fixedTextLabel = nil;

    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.delegate = _internal;
    _textView.editable = YES;
    _textView.opaque = NO;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.scrollsToTop = NO;
    [self addSubview:_textView];
  }
  return self;
}

- (void)dealloc {
  [_internal release];
  [_textView release];
  [_placeholderLabel release];
  [_placeholder release];
  [_fixedText release];
  [_fixedTextLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updatePlaceholder {
  if (_placeholder && !_editing && !_textView.text.length) {
    if (!_placeholderLabel) {
      _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      _placeholderLabel.backgroundColor = [UIColor clearColor];
      [self addSubview:_placeholderLabel];
    }
    
    if (_textView.textColor == [UIColor whiteColor]) {
      _placeholderLabel.textColor = [UIColor whiteColor];
    } else {
      _placeholderLabel.textColor = [UIColor grayColor];
    }
    _placeholderLabel.font = _textView.font;
    _placeholderLabel.textAlignment = _textView.textAlignment;
    _placeholderLabel.text = _placeholder;
    [self bringSubviewToFront:_placeholderLabel];
    _placeholderLabel.hidden = NO;
  } else {
    _placeholderLabel.hidden = YES;
  }
}

- (CGFloat)heightThatFits:(BOOL*)overflowed {
  CGSize characterSize = [@"M" sizeWithFont:_textView.font];
  CGFloat minHeight = _minNumberOfLines * characterSize.height;
  CGFloat maxHeight = _maxNumberOfLines * characterSize.height;
  CGFloat maxWidth = self.width - (kPaddingX*2 + kTextViewInset);
  
  NSString* text = _textView.text;
  if (!text.length) {
    text = @"M";
  }

  CGSize textSize = [text sizeWithFont:_textView.font
    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat newHeight = textSize.height;
  if ([text characterAtIndex:text.length-1] == 10) {
    newHeight += characterSize.height;
  }
  if (_showsExtraLine) {
    newHeight += characterSize.height;
  }

  if (overflowed) {
    *overflowed = maxHeight && newHeight > maxHeight;
  }

  if (newHeight < minHeight) {
    newHeight = minHeight;
  }
  if (maxHeight && newHeight > maxHeight) {
    newHeight = maxHeight;
  }
  
  return newHeight + kPaddingY*2;
}

- (void)constrainToText {
  CGFloat oldHeight = self.height;
  CGFloat newHeight = [self heightThatFits:&_overflowed];
  CGFloat diff = newHeight - oldHeight;
  
  if (oldHeight && diff) {
    if ([_delegate respondsToSelector:@selector(textEditor:shouldResizeBy:)]) {
      if (![_delegate textEditor:self shouldResizeBy:diff]) {
        return;
      }
    }
    
    self.frame = TTRectContract(self.frame, 0, -diff);
  }
}

- (BOOL)shouldChangeText:(NSString*)text inRange:(NSUInteger)location {
  if (_fixedText && location < _fixedText.length) {
    return NO;
  }
  
  return YES;
}

- (void)didChangeText {
  if (_autoresizesToText) {
    [self constrainToText];
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
  _textView.frame = CGRectMake(kPaddingX, kOffsetY, self.width-kPaddingX*2, self.height-kOffsetY);
  if (!_overflowed) {
    _textView.contentOffset = CGPointMake(0, 0);
  }
  _placeholderLabel.frame = _textView.frame;
    
  if (_fixedTextLabel) {
    [_fixedTextLabel sizeToFit];
    _fixedTextLabel.frame = CGRectMake(_textView.left+kPaddingX, _textView.top+kPaddingY,
      _fixedTextLabel.width+2, _fixedTextLabel.height+4);
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat height = [self heightThatFits:nil];
  return CGSizeMake(size.width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDelegate:(id<TTTextEditorDelegate>)delegate {
  _delegate = delegate;
  _internal.delegate = delegate;
}

- (NSString*)text {
  return _textView.text;
}

- (void)setText:(NSString*)text {
  if (_fixedText && text) {
    _textView.text = [_fixedText stringByAppendingString:text];
  } else {
    _textView.text = text;
  }
  [self updatePlaceholder];
  [self constrainToText];
}

- (void)setPlaceholder:(NSString*)placeholder {
  [_placeholder release];
  _placeholder = [placeholder copy];
  [self updatePlaceholder];
}

- (void)setFixedText:(NSString*)text {
  [_fixedText release];
  _fixedText = [text copy];
  
  if (_fixedText && !_fixedTextLabel) {
    _fixedTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _fixedTextLabel.textColor = [UIColor grayColor];
    _fixedTextLabel.font = _textView.font;
    _fixedTextLabel.contentMode = UIViewContentModeBottom;
    [self addSubview:_fixedTextLabel];
  }

  _fixedTextLabel.hidden = !_fixedText;
  _fixedTextLabel.text = _fixedText;
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
