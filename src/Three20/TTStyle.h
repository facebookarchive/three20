#import "Three20/TTGlobal.h"

@protocol TTStyleDelegate;
@class TTShape;

@interface TTStyle : NSObject {
  TTStyle* _next;
}

@property(nonatomic,retain) TTStyle* next;

- (id)initWithNext:(TTStyle*)next;

- (BOOL)drawRect:(CGRect)rect shape:(TTShape*)shape delegate:(id<TTStyleDelegate>)delegate;

- (TTStyle*)firstStyleOfClass:(Class)cls;

- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTContentStyle : TTStyle

+ (TTContentStyle*)styleWithNext:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Causes all layers going forward to use a particular shape.
 */
@interface TTShapeStyle : TTStyle {
  TTShape* _shape;
}

@property(nonatomic,retain) TTShape* shape;

+ (TTShapeStyle*)styleWithShape:(TTShape*)shape next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTInsetStyle : TTStyle {
  UIEdgeInsets _inset;
}

@property(nonatomic) UIEdgeInsets inset;

+ (TTInsetStyle*)styleWithInset:(UIEdgeInsets)inset next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTextStyle : TTStyle {
  UIFont* _font;
  UIColor* _color;
  UIColor* _shadowColor;
  CGSize _shadowOffset;
}

@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) UIColor* color;
@property(nonatomic,retain) UIColor* shadowColor;
@property(nonatomic) CGSize shadowOffset;

+ (TTTextStyle*)styleWithFont:(UIFont*)font next:(TTStyle*)next;
+ (TTTextStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next;
+ (TTTextStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color next:(TTStyle*)next;
+ (TTTextStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color
                shadowColor:(UIColor*)shadowColor shadowOffset:(CGSize)shadowOffset
                next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTImageStyle : TTStyle {
  NSString* _imageURL;
  UIImage* _image;
  UIImage* _defaultImage;
}

@property(nonatomic,copy) NSString* imageURL;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,retain) UIImage* defaultImage;

+ (TTImageStyle*)styleWithImageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
                 next:(TTStyle*)next;
+ (TTImageStyle*)initWithImage:(UIImage*)image defaultImage:(UIImage*)defaultImage
                 next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTSolidFillStyle : TTStyle {
  UIColor* _color;
}

@property(nonatomic,retain) UIColor* color;

+ (TTSolidFillStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTLinearGradientFillStyle : TTStyle {
  UIColor* _color1;
  UIColor* _color2;
}

@property(nonatomic,retain) UIColor* color1;
@property(nonatomic,retain) UIColor* color2;

+ (TTLinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                              next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTReflectiveFillStyle : TTStyle {
  UIColor* _color;
}

@property(nonatomic,retain) UIColor* color;

+ (TTReflectiveFillStyle*)styleWithColor:(UIColor*)color next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTShadowStyle : TTStyle {
  UIColor* _color;
  CGFloat _blur;
  CGSize _offset;
}

@property(nonatomic,retain) UIColor* color;
@property(nonatomic) CGFloat blur;
@property(nonatomic) CGSize offset;

+ (TTShadowStyle*)styleWithColor:(UIColor*)color blur:(CGFloat)blur offset:(CGSize)offset
                  next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTInnerShadowStyle : TTShadowStyle
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTSolidBorderStyle : TTStyle {
  UIColor* _color;
  CGFloat _width;
}

@property(nonatomic,retain) UIColor* color;
@property(nonatomic) CGFloat width;

+ (TTSolidBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTFourBorderStyle : TTStyle {
  UIColor* _top;
  UIColor* _right;
  UIColor* _bottom;
  UIColor* _left;
  CGFloat _width;
}

@property(nonatomic,retain) UIColor* top;
@property(nonatomic,retain) UIColor* right;
@property(nonatomic,retain) UIColor* bottom;
@property(nonatomic,retain) UIColor* left;
@property(nonatomic) CGFloat width;

+ (TTFourBorderStyle*)styleWithTop:(UIColor*)top right:(UIColor*)right
                      bottom:(UIColor*)bottom left:(UIColor*)left width:(CGFloat)width
                      next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTBevelBorderStyle : TTStyle {
  UIColor* _highlight;
  UIColor* _shadow;
  CGFloat _width;
  NSInteger _lightSource;
}

@property(nonatomic,retain) UIColor* highlight;
@property(nonatomic,retain) UIColor* shadow;
@property(nonatomic) CGFloat width;
@property(nonatomic) NSInteger lightSource;

+ (TTBevelBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(TTStyle*)next;

+ (TTBevelBorderStyle*)styleWithHighlight:(UIColor*)highlight shadow:(UIColor*)shadow
                       width:(CGFloat)width lightSource:(NSInteger)lightSource next:(TTStyle*)next;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTStyleDelegate

- (void)drawContent:(CGRect)rect withStyle:(TTStyle*)style shape:(TTShape*)shape;

@end
