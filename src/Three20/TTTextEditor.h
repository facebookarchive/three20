#import "Three20/TTStyledView.h"

@protocol TTTextEditorDelegate;
@class TTTextEditorInternal;

@interface TTTextEditor : TTStyledView {
  id<TTTextEditorDelegate> _textDelegate;
  TTTextEditorInternal* _internal;
  NSString* _placeholder;
  NSString* _fixedText;
  UITextView* _textView;
  UILabel* _placeholderLabel;
  UILabel* _fixedTextLabel;
  NSInteger _minNumberOfLines;
  NSInteger _maxNumberOfLines;
  BOOL _editing;
  BOOL _overflowed;
  BOOL _autoresizesToText;
  BOOL _showsExtraLine;
}

@property(nonatomic,assign) id<TTTextEditorDelegate> textDelegate;
@property(nonatomic,readonly) UITextView* textView;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic,copy) NSString* fixedText;
@property(nonatomic,assign) NSString* text;
@property(nonatomic) NSInteger minNumberOfLines;
@property(nonatomic) NSInteger maxNumberOfLines;
@property(nonatomic,readonly) BOOL editing;
@property(nonatomic) BOOL autoresizesToText;
@property(nonatomic) BOOL showsExtraLine;

- (void)scrollContainerToCursor:(UIScrollView*)scrollView;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTTextEditorDelegate <UITextViewDelegate>

@optional

- (BOOL)textEditor:(TTTextEditor*)textEditor shouldResizeBy:(CGFloat)height;
- (BOOL)textEditorShouldReturn:(TTTextEditor*)textEditor;

@end
