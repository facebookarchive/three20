#import "Three20/TTGlobal.h"

@protocol TTTextEditorDelegate;
@class TTTextEditorInternal;

@interface TTTextEditor : UIView {
  id<TTTextEditorDelegate> _delegate;
  TTTextEditorInternal* _internal;
  UITextView* textView;
  UILabel* _placeholderLabel;
  UILabel* fixedTextLabel;
  NSString* _placeholder;
  NSString* fixedText;
  UIFont* font;
  UIColor* textColor;
  UITextAlignment textAlignment;
  UIReturnKeyType returnKeyType;
  int minNumberOfLines;
  BOOL editing;
  BOOL multiline;
  BOOL autoresizeToText;
  BOOL showExtraLine;
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

- (void)textEditor:(TTTextEditor*)textEditor didResizeBy:(CGFloat)height;

@end
