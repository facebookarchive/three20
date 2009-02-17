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

@synthesize delegate = _delegate, textView, placeholder = _placeholder, fixedText, minNumberOfLines, editing,
  multiline, autoresizeToText, showExtraLine, font, textColor, textAlignment, returnKeyType;

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _delegate = nil;
    _internal = [[TTTextEditorInternal alloc] initWithTextEditor:self];
    editing = NO;
    multiline = YES;
    _placeholder = nil;
    fixedText = nil;
    autoresizeToText = YES;
    showExtraLine = NO;
    minNumberOfLines = 0;
    self.font = [UIFont systemFontOfSize:15];
    self.textColor = [UIColor blackColor];
    textAlignment = UITextAlignmentLeft;
    returnKeyType = UIReturnKeyDefault;
    textView = nil;
    _placeholderLabel = nil;
    fixedTextLabel = nil;
  }
  return self;
}

- (void)dealloc {
  [_internal release];
  [textView release];
  [_placeholderLabel release];
  [_placeholder release];
  [fixedText release];
  [font release];
  [textColor release];
  [_placeholder release];
  [fixedTextLabel release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateText {
  if (!textView) {
    textView = [[UITextView alloc] initWithFrame:CGRectMake(4, -2, 0, 0)];
    textView.delegate = _internal;
    textView.editable = YES;
    textView.opaque = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = textColor;
    textView.textAlignment = textAlignment;
    textView.returnKeyType = returnKeyType;
    textView.font = font;
    textView.scrollsToTop = NO;
    [self addSubview:textView];

    if (fixedTextLabel) {
      [self bringSubviewToFront:fixedTextLabel];
    }
  }
}

- (void)updatePlaceholder {
  if (_placeholder && !editing && !textView.text.length) {
    if (!_placeholderLabel) {
      _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      if (textColor == [UIColor whiteColor]) {
        _placeholderLabel.textColor = [UIColor whiteColor];
      } else {
        _placeholderLabel.textColor = [UIColor grayColor];
      }
      _placeholderLabel.backgroundColor = [UIColor clearColor];
      [self addSubview:_placeholderLabel];
    }
    
    _placeholderLabel.font = font;
    _placeholderLabel.textAlignment = textAlignment;
    _placeholderLabel.text = _placeholder;
    [self bringSubviewToFront:_placeholderLabel];
    _placeholderLabel.hidden = NO;
  } else {
    _placeholderLabel.hidden = YES;
  }
}

- (void)focus {
  [self updateText];
  [textView becomeFirstResponder];
}

- (void)constrainToBounds:(CGRect)frame {
  textView.frame = CGRectMake(textView.left, textView.top,
    frame.size.width-4, (frame.size.height*3)-kPaddingY);
  
  self.frame = frame;
}

- (void)constrainToText:(BOOL)onlyIfNeeded {
  NSString* text = self.text.length ? self.text : @"M";
  CGSize textSize = [text sizeWithFont:font
    constrainedToSize:CGSizeMake(self.frame.size.width - kPaddingX*2, CGFLOAT_MAX)
    lineBreakMode:UILineBreakModeWordWrap];

  CGFloat lineHeight = [@"Mg" sizeWithFont:textView.font].height;
  CGFloat minHeight = minNumberOfLines * lineHeight;
  CGFloat newHeight = textSize.height + kPaddingY;
  if (newHeight < minHeight) {
    newHeight = minHeight;
  }
  if (showExtraLine) {
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
  if (fixedText && location < fixedText.length) {
    return NO;
  }
  
  if (!multiline && [text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  } else {
    return YES;
  }
}

- (void)didChangeText {
  if (autoresizeToText) {
    [self constrainToText:YES];
  }
}

- (void)didBeginEditing {
  editing = YES;
  [self updatePlaceholder];
}

- (void)didEndEditing {
  if (editing) {
    editing = NO;
    [self updatePlaceholder];
  }
}

//- (void)textViewDidChangeSelection:(UITextView *)textView {
//  // Workaround for weird bug - if user touches and holds placeholder, keyboard appears
//  // but textViewDidBeginEditing isn't called, so we call it here
//  if (!editing) {
//    [self textViewDidBeginEditing:textView];
//  }
//}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  if (autoresizeToText) {
    [self constrainToText:NO];
  } else {
    textView.frame = CGRectMake(kPadding, kPadding,
      self.frame.size.width-kPadding*2, self.frame.size.height-kPadding*2);
  }
  _placeholderLabel.frame = CGRectMake(kPadding, kPadding,
    self.frame.size.width-kPadding*2, self.frame.size.height-kPadding*2);
    
  if (fixedTextLabel) {
    [fixedTextLabel sizeToFit];
    fixedTextLabel.frame = CGRectMake(textView.left+kPadding, textView.top+kPadding,
      fixedTextLabel.width+2, fixedTextLabel.height+4);
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(focus) userInfo:nil
    repeats:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (UITextView*)textView {
  [self updateText];
  return textView;
}

- (void)setPlaceholder:(NSString*)placeholder {
  [_placeholder release];
  _placeholder = [placeholder copy];
  
  [self updatePlaceholder];
}

- (NSString*)text {
  return textView.text;
}

- (void)setText:(NSString*)aText {
  [self updateText];
  if (fixedText && aText) {
    textView.text = [fixedText stringByAppendingString:aText];
  } else {
    textView.text = aText;
  }
  [self updatePlaceholder];
  [self setNeedsLayout];
}

- (void)setDelegate:(id<TTTextEditorDelegate>)delegate {
  _delegate = delegate;
  _internal.delegate = delegate;
}

- (void)setFixedText:(NSString*)aText {
  [fixedText release];
  fixedText = [aText copy];
  
  if (fixedText && !fixedTextLabel) {
    fixedTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    fixedTextLabel.textColor = [UIColor grayColor];
    fixedTextLabel.font = font;
    fixedTextLabel.contentMode = UIViewContentModeBottom;
    [self addSubview:fixedTextLabel];
  }

  fixedTextLabel.hidden = !fixedText;
  fixedTextLabel.text = fixedText;
}

- (void)setFont:(UIFont*)aFont {
  [font release];
  font = [aFont retain];
  textView.font = font;
}

- (void)setTextColor:(UIColor*)aColor {
  [textColor release];
  textColor = [aColor retain];
  textView.textColor = textColor;
}

- (void)setTextAlignment:(UITextAlignment)alignment {
  textAlignment = alignment;
  textView.textAlignment = _placeholderLabel.textAlignment = alignment;
}

- (void)setReturnKeyType:(UIReturnKeyType)aType {
  returnKeyType = aType;
  textView.returnKeyType = returnKeyType;
}

- (void)scrollContainerToCursor:(UIScrollView*)scrollView {
  if (textView.hasText) {
    if (scrollView.contentSize.height > scrollView.height) {
      NSRange range = textView.selectedRange;
      if (range.location == textView.text.length) {
        [scrollView scrollRectToVisible:CGRectMake(0,scrollView.contentSize.height-1,1,1)
          animated:NO];
      }
    } else {
      [scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
    }
  }
}

@end
