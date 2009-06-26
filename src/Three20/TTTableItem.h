#import "Three20/TTGlobal.h"

@class TTStyledText, TTStyle;

//typedef enum {
//  TTItemStyleDefault,
//  TTItemStyleLink,
//  TTItemStyleButton,
//  TTItemStyleMoreButton,
//  TTItemStyleCaptionLeft,
//  TTItemStyleCaptionRight,
//  TTItemStyleCaptionBelow,
//  TTItemStyleText,
//  TTItemStyleGrayText,
//  TTItemStyleSummary,
//} TTItemStyle;
//
@interface TTTableItem : NSObject {
  NSString* _text;
  NSString* _caption;
  NSString* _URL;
  NSString* _accessoryURL;
}
  
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* caption;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSString* accessoryURL;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text URL:(NSString*)URL;

@end

@interface TTTextTableItem : TTTableItem
@end

@interface TTGrayTextTableItem : TTTextTableItem
@end

@interface TTSummaryTableItem : TTTableItem
@end

@interface TTLinkTableItem : TTTableItem
@end

@interface TTButtonTableItem : TTLinkTableItem
@end

@interface TTMoreButtonTableItem : TTTableItem {
  BOOL _isLoading;
  NSString* _subtitle;
}

@property(nonatomic) BOOL isLoading;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle;

@end

@interface TTTitledTableItem : TTLinkTableItem {
  NSString* _title;
}

@property(nonatomic,copy) NSString* title;

- (id)initWithTitle:(NSString*)title text:(NSString*)text;
- (id)initWithTitle:(NSString*)title text:(NSString*)text URL:(NSString*)URL;

@end

@interface TTSubtextTableItem : TTTableItem {
  NSString* _subtext;
}

@property(nonatomic,copy) NSString* subtext;

- (id)initWithText:(NSString*)text subtext:(NSString*)subtext;
- (id)initWithText:(NSString*)text subtext:(NSString*)subtext URL:(NSString*)URL;

@end

@interface TTImageTableItem : TTTableItem {
  UIImage* _defaultImage;
  NSString* _image;
  TTStyle* _imageStyle;
}

@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,copy) NSString* image;
@property(nonatomic,retain) TTStyle* imageStyle;

- (id)initWithText:(NSString*)text URL:(NSString*)URL image:(NSString*)image;

- (id)initWithText:(NSString*)text URL:(NSString*)URL image:(NSString*)image
  defaultImage:(UIImage*)image;

@end

@interface TTIconTableItem : TTImageTableItem
@end

@interface TTStyledTextTableItem : TTTableItem {
  TTStyledText* _styledText;
  UIEdgeInsets _margin;
  UIEdgeInsets _padding;
}

@property(nonatomic,retain) TTStyledText* styledText;
@property(nonatomic) UIEdgeInsets margin;
@property(nonatomic) UIEdgeInsets padding;

- (id)initWithStyledText:(TTStyledText*)text;
- (id)initWithStyledText:(TTStyledText*)text URL:(NSString*)URL;

@end

@interface TTStatusTableItem : TTTableItem {
  BOOL _sizeToFit;
}

@property(nonatomic) BOOL sizeToFit;

@end

@interface TTActivityTableItem : TTStatusTableItem
@end

@interface TTErrorTableItem : TTStatusTableItem {
  UIImage* _image;
  NSString* _subtitle;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle image:(UIImage*)image;

@end

@interface TTTextFieldTableItem : TTTableItem {
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

@interface TTTextViewTableItem : TTTableItem {
  id<UITextViewDelegate> _delegate;
  NSString* _placeholder;
}

@property(nonatomic,assign) id<UITextViewDelegate> delegate;
@property(nonatomic,copy) NSString* placeholder;

@end

@interface TTSwitchTableItem : TTTableItem {
  BOOL _on;
}

@property(nonatomic) BOOL on;

- (id)initWithText:(NSString*)text on:(BOOL)on;

@end
