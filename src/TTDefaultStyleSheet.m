#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTDefaultStyleSheet

///////////////////////////////////////////////////////////////////////////////////////////////////
// styles

- (TTStyle*)linkText {
  return
    [TTTextStyle styleWithColor:self.linkTextColor next:nil];
}

- (TTStyle*)linkTextHighlighted {
  return
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-3, -4, -3, -4) next:
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5] next:
    [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.25] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(3, 4, 3, 4) next:
    [TTTextStyle styleWithColor:self.linkTextColor next:nil]]]]];
}

- (TTStyle*)linkHighlighted {
  return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5] next:
    [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.4] next:nil]];
}

- (TTStyle*)thumbView:(UIControlState)state {
  if (state & UIControlStateHighlighted) {
    return
      [TTSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.6) next:
      [TTSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.4) width:1 next:nil]];
  } else {
    return
      [TTSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.4) width:1 next:nil];
  }
}

- (TTStyle*)toolbarButton:(UIControlState)state {
  return [self toolbarButtonForState:state
               shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
               tintColor:TTSTYLEVAR(navigationBarTintColor)
               font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)toolbarBackButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[TTRoundedLeftArrowShape shapeWithRadius:4.5]
          tintColor:TTSTYLEVAR(navigationBarTintColor)
          font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)toolbarForwardButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[TTRoundedRightArrowShape shapeWithRadius:4.5]
          tintColor:TTSTYLEVAR(navigationBarTintColor)
          font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)toolbarRoundButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED]
          tintColor:TTSTYLEVAR(navigationBarTintColor)
          font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)blackToolbarButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(10, 10, 10)
          font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)blackToolbarForwardButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[TTRoundedRightArrowShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(10, 10, 10)
          font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)blackToolbarRoundButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED]
          tintColor:RGBCOLOR(10, 10, 10)
          font:TTSTYLEVAR(toolbarButtonFont)];
}

- (TTStyle*)searchTextField {
  return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:13] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 2, 0) next:
    [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.6) blur:0 offset:CGSizeMake(0, 1) next:
    [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
    [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
    [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
                        width:1 lightSource:270 next:nil]]]]]];
}


- (TTStyle*)searchBar {
  UIColor* color = TTSTYLEVAR(searchBarTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.2];
  UIColor* shadow = [color multiplyHue:0 saturation:0 value:0.82];
  return
    [TTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [TTFourBorderStyle styleWithTop:nil right:nil bottom:shadow left:nil width:1 next:nil]];
}

- (TTStyle*)searchBarBottom {
  UIColor* color = TTSTYLEVAR(searchBarTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.2];
  UIColor* shadow = [color multiplyHue:0 saturation:0 value:0.82];
  return
    [TTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [TTFourBorderStyle styleWithTop:shadow right:nil bottom:nil left:nil width:1 next:nil]];
}

- (TTStyle*)tableHeader {
  return
    [TTReflectiveFillStyle styleWithColor:self.tableHeaderTintColor next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, 0, 0, 0) next:
    [TTFourBorderStyle styleWithTop:nil right:nil bottom:RGBACOLOR(0,0,0,0.15)
                       left:nil width:1 next:nil]]];
}

- (TTStyle*)pickerCell:(UIControlState)state {
  if (state & UIControlStateSelected) {
    return
      [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
      [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(79, 144, 255)
                                 color2:RGBCOLOR(49, 90, 255) next:
      [TTFourBorderStyle styleWithTop:RGBCOLOR(53, 94, 255)
                         right:RGBCOLOR(53, 94, 255) bottom:RGBCOLOR(53, 94, 255)
                         left:RGBCOLOR(53, 94, 255) width:1 next:nil]]]];

   } else {
    return
     [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
     [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(221, 231, 248)
                                color2:RGBACOLOR(188, 206, 241, 1) next:
     [TTFourBorderStyle styleWithTop:RGBCOLOR(161, 187, 283)
                        right:RGBCOLOR(118, 130, 214) bottom:RGBCOLOR(118, 130, 214)
                        left:RGBCOLOR(161, 187, 283) width:1 next:nil]]]];
  }
}

- (TTStyle*)searchTableShadow {
  return
    [TTLinearGradientFillStyle styleWithColor1:RGBACOLOR(0, 0, 0, 0.18)
                               color2:[UIColor clearColor] next:
    [TTFourBorderStyle styleWithTop:RGBCOLOR(130, 130, 130) right:nil bottom:nil left:nil
                       width: 1 next:nil]];
}

- (TTStyle*)blackBezel {
  return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.7) next:nil]];
}

- (TTStyle*)whiteBezel {
  return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
    [TTSolidFillStyle styleWithColor:RGBCOLOR(255, 255, 255) next:
    [TTSolidBorderStyle styleWithColor:RGBCOLOR(178, 178, 178) width:1 next:nil]]];
}

- (TTStyle*)badge {
  return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
    [TTShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:3 offset:CGSizeMake(0, 4) next:
    [TTReflectiveFillStyle styleWithColor:RGBCOLOR(221, 17, 27) next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
    [TTSolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
    [TTPaddingStyle styleWithPadding:UIEdgeInsetsMake(-4, 0, -4, 0) next:
    [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]
                 color:[UIColor whiteColor] next:nil]]]]]]]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public colors

- (UIColor*)navigationBarTintColor {
  return RGBCOLOR(119, 140, 168);
}

- (UIColor*)toolbarTintColor {
  return RGBCOLOR(109, 132, 162);
}

- (UIColor*)searchBarTintColor {
  return RGBCOLOR(200, 200, 200);
}

- (UIColor*)linkTextColor {
  return RGBCOLOR(87, 107, 149);
}

- (UIColor*)moreLinkTextColor {
  return RGBCOLOR(36, 112, 216);
}

- (UIColor*)tableActivityTextColor {
  return RGBCOLOR(99, 109, 125);
}

- (UIColor*)tableErrorTextColor {
  return RGBCOLOR(99, 109, 125);
}

- (UIColor*)tableSubTextColor {
  return RGBCOLOR(99, 109, 125);
}

- (UIColor*)tableTitleTextColor {
  return RGBCOLOR(99, 109, 125);
}

- (UIColor*)placeholderTextColor {
  return RGBCOLOR(180, 180, 180);
}

- (UIColor*)searchTableBackgroundColor {
  return RGBCOLOR(235, 235, 235);
}

- (UIColor*)searchTableSeparatorColor {
  return [UIColor colorWithWhite:0.85 alpha:1];
}

- (UIColor*)tableHeaderTextColor {
  return nil;
}

- (UIColor*)tableHeaderShadowColor {
  return nil;
}

- (UIColor*)tableHeaderTintColor {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public fonts

- (UIFont*)toolbarButtonFont {
  return [UIFont boldSystemFontOfSize:12];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIColor*)toolbarButtonColorWithTintColor:(UIColor*)color forState:(UIControlState)state {
  if (state & UIControlStateHighlighted) {
    if (color.value < 0.2) {
      return [color addHue:0 saturation:0 value:0.2];
    } else if (color.saturation > 0.3) {
      return [color multiplyHue:1 saturation:1 value:0.4];
    } else {
      return [color multiplyHue:1 saturation:2.3 value:0.64];
    }
  } else if (state & UIControlStateDisabled) {
    return [color multiplyHue:1 saturation:0.5 value:1];
  } else {
    if (color.saturation < 0.5) {
      return [color multiplyHue:1 saturation:1.6 value:0.97];
    } else {
      return [color multiplyHue:1 saturation:1.25 value:0.75];
    }
  }
}

- (UIColor*)toolbarButtonTextColorForState:(UIControlState)state {
  if (state & UIControlStateDisabled) {
    return [UIColor colorWithWhite:1 alpha:0.4];
  } else {
    return [UIColor whiteColor];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTStyle*)toolbarButtonForState:(UIControlState)state shape:(TTShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font {
  UIColor* stateTintColor = [self toolbarButtonColorWithTintColor:tintColor forState:state];
  UIColor* stateTextColor = [self toolbarButtonTextColorForState:state];

  return 
    [TTShapeStyle styleWithShape:shape next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
    [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.55) blur:0 offset:CGSizeMake(0, 1) next:
    [TTReflectiveFillStyle styleWithColor:stateTintColor next:
    [TTBevelBorderStyle styleWithHighlight:[stateTintColor multiplyHue:1 saturation:0.9 value:0.7]
                        shadow:[stateTintColor multiplyHue:1 saturation:0.5 value:0.45]
                        width:1 lightSource:270 next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [TTBevelBorderStyle styleWithHighlight:nil shadow:RGBACOLOR(0,0,0,0.15)
                        width:1 lightSource:270 next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(4, 5, 2, 7) next:
    [TTTextStyle styleWithFont:font
                 color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]]];
}

@end
