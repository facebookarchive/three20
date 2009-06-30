#import "Three20/TTGlobal.h"

@class TTStyledText, TTStyle;

@interface TTTableItem : NSObject
@end

@interface TTTableLinkedItem : TTTableItem {
  NSString* _URL;
  NSString* _accessoryURL;
}

@property(nonatomic,copy) NSString* URL;
@property(nonatomic,copy) NSString* accessoryURL;

@end

@interface TTTableTextItem : TTTableLinkedItem {
  NSString* _text;
}
  
@property(nonatomic,copy) NSString* text;

+ (id)itemWithText:(NSString*)text;
+ (id)itemWithText:(NSString*)text URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL;

@end

@interface TTTableCaptionedItem : TTTableTextItem {
  NSString* _caption;
}

@property(nonatomic,copy) NSString* caption;

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption;
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL
      accessoryURL:(NSString*)accessoryURL;

@end

@interface TTTableRightCaptionedItem : TTTableCaptionedItem
@end

@interface TTTableBelowCaptionedItem : TTTableCaptionedItem
@end

@interface TTTableLongTextItem : TTTableTextItem
@end

@interface TTTableGrayTextItem : TTTableTextItem
@end

@interface TTTableSummaryItem : TTTableTextItem
@end

@interface TTTableLink : TTTableTextItem
@end

@interface TTTableButton : TTTableTextItem
@end

@interface TTTableMoreButton : TTTableBelowCaptionedItem {
  BOOL _isLoading;
}

@property(nonatomic) BOOL isLoading;

@end

@interface TTTableImageItem : TTTableTextItem {
  NSString* _image;
  UIImage* _defaultImage;
  TTStyle* _imageStyle;
}

@property(nonatomic,copy) NSString* image;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,retain) TTStyle* imageStyle;

+ (id)itemWithText:(NSString*)text image:(NSString*)image;
+ (id)itemWithText:(NSString*)text URL:(NSString*)URL image:(NSString*)image;
+ (id)itemWithText:(NSString*)text URL:(NSString*)URL image:(NSString*)image
      defaultImage:(UIImage*)defaultImage;

@end

@interface TTTableRightImageItem : TTTableImageItem
@end

@interface TTTableStatusItem : TTTableItem {
  BOOL _sizeToFit;
}

@property(nonatomic) BOOL sizeToFit;

@end

@interface TTTableActivityItem : TTTableStatusItem {
  NSString* _text;
}

@property(nonatomic,copy) NSString* text;

+ (id)itemWithText:(NSString*)text;

@end

@interface TTTableErrorItem : TTTableStatusItem {
  UIImage* _image;
  NSString* _title;
  NSString* _subtitle;
}

@property(nonatomic,retain) UIImage* image;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* subtitle;

+ (id)itemWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image;

@end

@interface TTTableStyledTextItem : TTTableLinkedItem {
  TTStyledText* _text;
  UIEdgeInsets _margin;
  UIEdgeInsets _padding;
}

@property(nonatomic,retain) TTStyledText* text;
@property(nonatomic) UIEdgeInsets margin;
@property(nonatomic) UIEdgeInsets padding;

+ (id)itemWithText:(TTStyledText*)text;
+ (id)itemWithText:(TTStyledText*)text URL:(NSString*)URL;
+ (id)itemWithText:(TTStyledText*)text URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL;

@end

@interface TTTableControlItem : TTTableItem {
  NSString* _caption;
  UIControl* _control;
}

@property(nonatomic,copy) NSString* caption;
@property(nonatomic,retain) UIControl* control;

+ (id)itemWithCaption:(NSString*)caption control:(UIControl*)control;

@end

@interface TTTableViewItem : TTTableItem {
  NSString* _caption;
  UIView* _view;
}

@property(nonatomic,copy) NSString* caption;
@property(nonatomic,retain) UIView* view;

+ (id)itemWithCaption:(NSString*)caption view:(UIView*)view;

@end
