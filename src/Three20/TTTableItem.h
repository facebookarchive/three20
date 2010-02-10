//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTStyledText, TTStyle;

@interface TTTableItem : NSObject <NSCoding> {
  id _userInfo;
}

@property(nonatomic,retain) id userInfo;

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

@interface TTTableCaptionItem : TTTableTextItem {
  NSString* _caption;
}

@property(nonatomic,copy) NSString* caption;

+ (id)itemWithText:(NSString*)text caption:(NSString*)caption;
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text caption:(NSString*)caption URL:(NSString*)URL
      accessoryURL:(NSString*)accessoryURL;

@end

@interface TTTableRightCaptionItem : TTTableCaptionItem
@end

@interface TTTableSubtextItem : TTTableCaptionItem
@end

@interface TTTableSubtitleItem : TTTableTextItem {
  NSString* _subtitle;
  NSString* _imageURL;
  UIImage* _defaultImage;
}

@property(nonatomic,copy) NSString* subtitle;
@property(nonatomic,copy) NSString* imageURL;
@property(nonatomic,retain) UIImage* defaultImage;

+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle;
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle URL:(NSString*)URL
      accessoryURL:(NSString*)accessoryURL;
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle imageURL:(NSString*)imageURL
      URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text subtitle:(NSString*)subtitle imageURL:(NSString*)imageURL
      defaultImage:(UIImage*)defaultImage URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL;

@end

@interface TTTableMessageItem : TTTableTextItem {
  NSString* _title;
  NSString* _caption;
  NSDate* _timestamp;
  NSString* _imageURL;
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* caption;
@property(nonatomic,retain) NSDate* timestamp;
@property(nonatomic,copy) NSString* imageURL;

+ (id)itemWithTitle:(NSString*)title caption:(NSString*)caption text:(NSString*)text
      timestamp:(NSDate*)timestamp URL:(NSString*)URL;
+ (id)itemWithTitle:(NSString*)title caption:(NSString*)caption text:(NSString*)text
      timestamp:(NSDate*)timestamp imageURL:(NSString*)imageURL URL:(NSString*)URL;

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

@interface TTTableMoreButton : TTTableSubtitleItem {
  BOOL _isLoading;
}

@property(nonatomic) BOOL isLoading;

@end

@interface TTTableImageItem : TTTableTextItem {
  NSString* _imageURL;
  UIImage* _defaultImage;
  TTStyle* _imageStyle;
}

@property(nonatomic,copy) NSString* imageURL;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,retain) TTStyle* imageStyle;

+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL;
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL
      defaultImage:(UIImage*)defaultImage URL:(NSString*)URL;
+ (id)itemWithText:(NSString*)text imageURL:(NSString*)imageURL
      defaultImage:(UIImage*)defaultImage imageStyle:(TTStyle*)imageStyle URL:(NSString*)URL;

@end

@interface TTTableRightImageItem : TTTableImageItem
@end

@interface TTTableActivityItem : TTTableItem {
  NSString* _text;
}

@property(nonatomic,copy) NSString* text;

+ (id)itemWithText:(NSString*)text;

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
