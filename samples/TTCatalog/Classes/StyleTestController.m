#import "StyleTestController.h"

@implementation StyleTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  UIScrollView* scrollView = [[[UIScrollView alloc] initWithFrame:TTNavigationFrame()] autorelease];
	scrollView.autoresizesSubviews = YES;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.backgroundColor = RGBCOLOR(216, 221, 231);
  self.view = scrollView;
  
  UIColor* black = RGBCOLOR(158, 163, 172);
  UIColor* blue = RGBCOLOR(191, 197, 208);
  UIColor* darkBlue = RGBCOLOR(109, 132, 162);
  
  NSArray* styles = [NSArray arrayWithObjects:
    // Rectangle
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTSolidBorderStyle styleWithColor:black width:1 next:nil]],

    // Rounded rectangle
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]],

    // Rounded left arrow
    [TTShapeStyle styleWithShape:[TTRoundedLeftArrowShape shapeWithRadius:5] next:
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]],

    // Partially rounded rectangle
    [TTShapeStyle styleWithShape:
      [TTRoundedRectangleShape shapeWithTopLeft:0 topRight:0 bottomRight:10 bottomLeft:10] next:
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]],
        
    // Drop shadow
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.5) blur:5 offset:CGSizeMake(2, 2) next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0.25, 0.25, 0.25, 0.25) next:
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-0.25, -0.25, -0.25, -0.25) next:
    [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]]]]],

    // Inner shadow
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.5) blur:6 offset:CGSizeMake(1, 1) next:
    [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]]],

    // Chiseled button
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
    [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
                               color2:RGBCOLOR(216, 221, 231) next:
    [TTSolidBorderStyle styleWithColor:blue width:1 next:nil]]]],
    
    // Embossed button
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
                               color2:RGBCOLOR(216, 221, 231) next:
    [TTFourBorderStyle styleWithTop:blue right:black bottom:black left:blue width:1 next:nil]]],
    
    // Toolbar button
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5] next:
    [TTShadowStyle styleWithColor:RGBCOLOR(255,255,255) blur:1 offset:CGSizeMake(0, 1) next:
    [TTReflectiveFillStyle styleWithColor:darkBlue next:
    [TTBevelBorderStyle styleWithHighlight:[darkBlue shadow]
                        shadow:[darkBlue multiplyHue:1 saturation:0.5 value:0.5]
                        width:1 lightSource:270 next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [TTBevelBorderStyle styleWithHighlight:nil shadow:RGBACOLOR(0,0,0,0.15)
                        width:1 lightSource:270 next:nil]]]]]],

    // Back button
    [TTShapeStyle styleWithShape:[TTRoundedLeftArrowShape shapeWithRadius:4.5] next:
    [TTShadowStyle styleWithColor:RGBCOLOR(255,255,255) blur:1 offset:CGSizeMake(0.4, 1) next:
    [TTReflectiveFillStyle styleWithColor:darkBlue next:
    [TTBevelBorderStyle styleWithHighlight:[darkBlue shadow]
                        shadow:[darkBlue multiplyHue:1 saturation:0.5 value:0.5]
                        width:1 lightSource:270 next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [TTBevelBorderStyle styleWithHighlight:nil shadow:RGBACOLOR(0,0,0,0.15)
                       width:1 lightSource:270 next:nil]]]]]],


    // Badge
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5) next:
    [TTShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.8) blur:2 offset:CGSizeMake(0, 5) next:
    [TTReflectiveFillStyle styleWithColor:[UIColor redColor] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1.5, -1.5, -1.5, -1.5) next:
    [TTSolidBorderStyle styleWithColor:[UIColor whiteColor] width:3 next:nil]]]]]],
    nil];
  
  CGFloat padding = 10;
  CGFloat viewWidth = scrollView.width/2;
  CGFloat viewHeight = 44;
  
  CGFloat x = 0;
  CGFloat y = 0;
  for (TTStyle* style in styles) {
    CGRect frame = CGRectMake(x, y, viewWidth, viewHeight + padding*2);
    TTStyledView* view = [[[TTStyledView alloc] initWithFrame:frame] autorelease];
    view.backgroundColor = scrollView.backgroundColor;
    view.backgroundInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    view.style = style;
    [scrollView addSubview:view];
    
    x += frame.size.width;
    if (x >= scrollView.width) {
      x = 0;
      y += frame.size.height;
    }
  }
  
  scrollView.contentSize = CGSizeMake(scrollView.width, y);
}

@end
