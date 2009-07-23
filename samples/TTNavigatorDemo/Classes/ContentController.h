#import <Three20/Three20.h>

typedef enum {
  ContentTypeNone,
  ContentTypeFood,
  ContentTypeNutrition,
  ContentTypeAbout,
  ContentTypeOrder,
} ContentType;

@interface ContentController : TTViewController {
  ContentType _contentType;
  NSString* _content;
  NSString* _text;
}

@property(nonatomic,copy) NSString* content;
@property(nonatomic,copy) NSString* text;

@end
