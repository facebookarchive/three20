#import "Three20/T3Global.h"

@interface T3TableField : NSObject {
  NSString* _text;
  NSString* _href;
}
  
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* href;

- (id)initWithText:(NSString*)text;
- (id)initWithText:(NSString*)text href:(NSString*)href;

@end

@interface T3TextTableField : T3TableField
@end

@interface T3GrayTextTableField : T3TextTableField
@end

@interface T3SummaryTableField : T3TableField
@end

@interface T3LinkTableField : T3TableField
@end

@interface T3ButtonTableField : T3LinkTableField
@end

@interface T3MoreButtonTableField : T3TableField {
  BOOL _loading;
  NSString* _subtitle;
}

@property(nonatomic) BOOL loading;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle;

@end

@interface T3TitledTableField : T3LinkTableField {
  NSString* _title;
}

@property(nonatomic,copy) NSString* title;

- (id)initWithTitle:(NSString*)title text:(NSString*)text;
- (id)initWithTitle:(NSString*)title text:(NSString*)text href:(NSString*)href;

@end

@interface T3ImageTableField : T3TableField {
  UIImage* _defaultImage;
  NSString* _image;
}

@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,copy) NSString* image;

- (id)initWithText:(NSString*)text href:(NSString*)href image:(NSString*)image;

- (id)initWithText:(NSString*)text href:(NSString*)href image:(NSString*)image
  defaultImage:(UIImage*)image;

@end

@interface T3IconTableField : T3ImageTableField
@end

@interface T3StatusTableField : T3TableField {
  BOOL _sizeToFit;
}

@property(nonatomic) BOOL sizeToFit;

@end

@interface T3ActivityTableField : T3StatusTableField
@end

@interface T3ErrorTableField : T3StatusTableField {
  UIImage* _image;
  NSString* _subtitle;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithText:(NSString*)text subtitle:(NSString*)subtitle image:(UIImage*)image;

@end

@interface T3TextFieldTableField : T3TableField {
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

@interface T3TextViewTableField : T3TableField {
  id<UITextViewDelegate> _delegate;
  NSString* _placeholder;
}

@property(nonatomic,assign) id<UITextViewDelegate> delegate;
@property(nonatomic,copy) NSString* placeholder;

- (id)initWithText:(NSString*)text;

@end

@interface T3SwitchTableField : T3TableField {
  BOOL _on;

}

@property(nonatomic) BOOL on;

- (id)initWithText:(NSString*)text on:(BOOL)on;

@end
