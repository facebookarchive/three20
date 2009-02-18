#import "Three20/TTGlobal.h"

@protocol TTTextEditorDelegate;
@class TTTextEditorInternal;

@interface TTTextEditor : UIView {
  id<TTTextEditorDelegate> _delegate;
  TTTextEditorInternal* _internal;
  UITextView* _textView;
  UILabel* _placeholderLabel;
  UILabel* _fixedTextLabel;
  NSString* _placeholder;
  NSString* _fixedText;
  UIFont* _font;
  UIColor* _textColor;
  UITextAlignment _textAlignment;
  UIReturnKeyType _returnKeyType;
  int _minNumberOfLines;
  BOOL _editing;
  BOOL _multiline;
  BOOL _autoresizeToText;
  BOOL _showExtraLine;
}

@property(nonatomic,assign) id<TTTextEditorDelegate> delegate;
@property(nonatomic,readonly) UITextView* textView;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic,copy) NSString* fixedText;
@property(nonatomic,assign) NSString* text;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic) UITextAlignment textAlignment;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) int minNumberOfLines;
@property(nonatomic,readonly) BOOL editing;
@property(nonatomic) BOOL multiline;
@property(nonatomic) BOOL autoresizeToText;
@property(nonatomic) BOOL showExtraLine;

- (id)initWithFrame:(CGRect)frame;

- (void)scrollContainerToCursor:(UIScrollView*)scrollView;

@end

@protocol TTTextEditorDelegate <UITextViewDelegate>

@optional

- (void)textEditor:(TTTextEditor*)textEditor didResizeBy:(CGFloat)height;

@end
