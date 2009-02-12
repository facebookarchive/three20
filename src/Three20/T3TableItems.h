#import "Three20/T3Global.h"

@interface T3TableItem : NSObject
@end

@interface T3TextTableItem : T3TableItem {
  NSString* text;
}

@property(nonatomic,copy) NSString* text;

- (id)initWithText:(NSString*)text;

@end

@interface T3MessageTableItem : T3TextTableItem
@end

@interface T3TitleTableItem : T3TableItem {
  NSString* title;
}

@property(nonatomic,copy) NSString* title;

- (id)initWithTitle:(NSString*)title;

@end

@interface T3SummaryTableItem : T3TitleTableItem
@end

@interface T3LinkTableItem : T3TitleTableItem {
  NSString* href;
}

@property(nonatomic,copy) NSString* href;

- (id)initWithTitle:(NSString*)title href:(NSString*)href;

@end

@interface T3ButtonTableItem : T3LinkTableItem
@end

@interface T3KeyValueTableItem : T3LinkTableItem {
  NSString* value;
}

@property(nonatomic,copy) NSString* value;

- (id)initWithKey:(NSString*)key value:(NSString*)value;
- (id)initWithKey:(NSString*)key value:(NSString*)value href:(NSString*)href;

@end

@interface T3IconTableItem : T3LinkTableItem {
  UIImage* defaultImage;
  NSString* icon;
}

@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,copy) NSString* icon;

- (id)initWithTitle:(NSString*)title icon:(NSString*)icon href:(NSString*)href
  defaultImage:(UIImage*)image;

@end

@interface T3TextFieldTableItem : T3TableItem {
  id<UITextFieldDelegate> _delegate;
  NSString* _text;
  NSString* title;
  NSString* placeholder;
  UIReturnKeyType returnKeyType;
  UIKeyboardType keyboardType;
  UITextAutocapitalizationType autocapitalizationType;
  UITextAutocorrectionType autocorrectionType;
  UITextFieldViewMode clearButtonMode;
  BOOL secureTextEntry;

}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) UITextFieldViewMode clearButtonMode;
@property(nonatomic) BOOL secureTextEntry;

- (id)initWithTitle:(NSString*)title;

@end

@interface T3TextEditorTableItem : T3TableItem {
  id<UITextViewDelegate> _delegate;
  NSString* _placeholder;
}

@property(nonatomic,assign) id<UITextViewDelegate> delegate;

@property(nonatomic,copy) NSString* placeholder;

@end

@interface T3StatusTableItem : T3TableItem {
  BOOL sizeToFit;
}

@property(nonatomic) BOOL sizeToFit;

@end

@interface T3ActivityTableItem : T3StatusTableItem {
  NSString* title;
}

@property(nonatomic,copy) NSString* title;

- (id)initWithTitle:(NSString*)title;

@end

@interface T3ErrorTableItem : T3StatusTableItem {
  UIImage* image;
  NSString* title;
  NSString* subtitle;
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* subtitle;
@property(nonatomic,retain) UIImage* image;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image;

@end

@interface T3MoreLinkTableItem : T3TitleTableItem {
  BOOL loading;
  NSString* subtitle;
}

@property(nonatomic) BOOL loading;
@property(nonatomic,copy) NSString* subtitle;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle;

@end
