#import "Three20/TTGlobal.h"

@interface TTShape : NSObject

- (void)openPath:(CGRect)rect;
- (void)closePath:(CGRect)rect;

- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource;

/**
 * Opens the path, adds all edges, and closes the path.
 */
- (void)addToPath:(CGRect)rect;

- (void)addInverseToPath:(CGRect)rect;

- (UIEdgeInsets)insetsForSize:(CGSize)size;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTRectangleShape : TTShape

+ (TTRectangleShape*)shape;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTRoundedRectangleShape : TTShape {
  CGFloat _topLeftRadius;
  CGFloat _topRightRadius;
  CGFloat _bottomRightRadius;
  CGFloat _bottomLeftRadius;
}

@property(nonatomic) CGFloat topLeftRadius;
@property(nonatomic) CGFloat topRightRadius;
@property(nonatomic) CGFloat bottomRightRadius;
@property(nonatomic) CGFloat bottomLeftRadius;

+ (TTRoundedRectangleShape*)shapeWithRadius:(CGFloat)radius;

+ (TTRoundedRectangleShape*)shapeWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight
      bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTRoundedRightArrowShape : TTShape {
  CGFloat _radius;
}

@property(nonatomic) CGFloat radius;

+ (TTRoundedRightArrowShape*)shapeWithRadius:(CGFloat)radius;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTRoundedLeftArrowShape : TTShape {
  CGFloat _radius;
}

@property(nonatomic) CGFloat radius;

+ (TTRoundedLeftArrowShape*)shapeWithRadius:(CGFloat)radius;

@end
