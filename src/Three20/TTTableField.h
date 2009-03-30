#import "Three20/TTGlobal.h"

@class TTHTMLNode, TTHTMLLayout;

@interface TTTableField : NSObject {
  NSString* _text;
  NSString* _url;
}
  
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* url;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text url:(NSString*)url;

@end

@interface TTTextTableField : TTTableField
@end

@interface TTGrayTextTableField : TTTextTableField
@end

@interface TTSummaryTableField : TTTableField
@end

@interface TTLinkTableField : TTTableField
@end

@interface TTButtonTableField : TTLinkTableField
@end

@interface TTMoreButtonTableField : TTTableField {
  BOOL _isLoading;
  NSString* _subtitle;
}

@property(nonatomic) BOOL isLoading;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle;

@end

@interface TTTitledTableField : TTLinkTableField {
  NSString* _title;
}

@property(nonatomic,copy) NSString* title;

- (id)initWithTitle:(NSString*)title text:(NSString*)text;
- (id)initWithTitle:(NSString*)title text:(NSString*)text url:(NSString*)url;

@end

@interface TTSubtextTableField : TTTableField {
  NSString* _subtext;
}

@property(nonatomic,copy) NSString* subtext;

- (id)initWithText:(NSString*)text subtext:(NSString*)subtext;
- (id)initWithText:(NSString*)text subtext:(NSString*)subtext url:(NSString*)url;

@end

@interface TTImageTableField : TTTableField {
  UIImage* _defaultImage;
  NSString* _image;
}

@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,copy) NSString* image;

- (id)initWithText:(NSString*)text url:(NSString*)url image:(NSString*)image;

- (id)initWithText:(NSString*)text url:(NSString*)url image:(NSString*)image
  defaultImage:(UIImage*)image;

@end

@interface TTIconTableField : TTImageTableField
@end

@interface TTStatusTableField : TTTableField {
  BOOL _sizeToFit;
}

@property(nonatomic) BOOL sizeToFit;

@end

@interface TTActivityTableField : TTStatusTableField
@end

@interface TTErrorTableField : TTStatusTableField {
  UIImage* _image;
  NSString* _subtitle;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle image:(UIImage*)image;

@end

@interface TTTextFieldTableField : TTTableField {
  id<UITextFieldDelegate> _delegate;
  NSString* _title;
  NSString* _placeholder;
  UIReturnKeyType _returnKeyType;
  UIKeyboardType _keyboardType;
  UITextAutocapitalizationType _autocapitalizationType;
  UITextAutocorrectionType _autocorrectionType;
  UITextFieldViewMode _clearButtonMode;
  BOOL _secureTextEntry;

}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) UITextFieldViewMode clearButtonMode;
@property(nonatomic) BOOL secureTextEntry;

- (id)initWithTitle:(NSString*)title;
- (id)initWithTitle:(NSString*)title text:(NSString*)text;

@end

@interface TTTextViewTableField : TTTableField {
  id<UITextViewDelegate> _delegate;
  NSString* _placeholder;
}

@property(nonatomic,assign) id<UITextViewDelegate> delegate;
@property(nonatomic,copy) NSString* placeholder;

- (id)initWithText:(NSString*)text;

@end

@interface TTSwitchTableField : TTTableField {
  BOOL _on;
}

@property(nonatomic) BOOL on;

- (id)initWithText:(NSString*)text on:(BOOL)on;

@end

@interface TTHTMLTableField : TTTableField {
  TTHTMLNode* _html;
  TTHTMLLayout* _layout;
}

@property(nonatomic,retain) TTHTMLNode* html;
@property(nonatomic,readonly) TTHTMLLayout* layout;

- (id)initWithHTML:(TTHTMLNode*)html;
- (id)initWithHTML:(TTHTMLNode*)html url:(NSString*)url;

@end
