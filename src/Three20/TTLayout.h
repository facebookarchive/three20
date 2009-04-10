#import "Three20/TTGlobal.h"

@interface TTLayout : NSObject

- (CGSize)layoutSubviews:(NSArray*)subviews forView:(UIView*)view;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTFlowLayout : TTLayout {
  CGFloat _padding;
  CGFloat _spacing;
}

@property(nonatomic) CGFloat padding;
@property(nonatomic) CGFloat spacing;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTGridLayout : TTLayout {
  NSInteger _columnCount;
  CGFloat _padding;
  CGFloat _spacing;
}

@property(nonatomic) NSInteger columnCount;
@property(nonatomic) CGFloat padding;
@property(nonatomic) CGFloat spacing;

@end
