#import "Three20/TTAppearance.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static TTAppearance* gAppearance = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTAppearance

@synthesize navigationBarTintColor = _navigationBarTintColor,
  toolbarTintColor = _toolbarTintColor,
  searchBarTintColor = _searchBarTintColor,
  linkTextColor = _linkTextColor,
  moreLinkTextColor = _moreLinkTextColor,
  tableActivityTextColor = _tableActivityTextColor, 
  tableErrorTextColor = _tableErrorTextColor, 
  tableSubTextColor = _tableSubTextColor, 
  tableTitleTextColor = _tableTitleTextColor, 
  placeholderTextColor = _placeholderTextColor, 
  searchTableBackgroundColor = _searchTableBackgroundColor,
  searchTableSeparatorColor = _searchTableSeparatorColor,
  tableHeaderTextColor = _tableHeaderTextColor,
  tableHeaderShadowColor = _tableHeaderShadowColor,
  tableHeaderTintColor = _tableHeaderTintColor,
  linkStyle = _linkStyle,
  linkHighlightedStyle = _linkHighlightedStyle,
  searchTextFieldStyle = _searchTextFieldStyle,
  searchBarStyle = _searchBarStyle,
  tableHeaderStyle = _tableHeaderStyle,
  pickerCellStyle = _pickerCellStyle,
  pickerCellSelectedStyle = _pickerCellSelectedStyle,
  searchTableShadowStyle = _searchTableShadowStyle,
  blackBezelStyle = _blackBezelStyle,
  whiteBezelStyle = _whiteBezelStyle;

+ (TTAppearance*)appearance {
  if (!gAppearance) {
    [self setAppearance:[[[TTAppearance alloc] init] autorelease]];
  }
  return gAppearance;
}

+ (void)setAppearance:(TTAppearance*)appearance {
  if (gAppearance != appearance) {
    [gAppearance release];
    gAppearance = [appearance retain];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = RGBCOLOR(119, 140, 168);//nil;
    self.toolbarTintColor = RGBCOLOR(109, 132, 162);
    self.searchBarTintColor = RGBCOLOR(200, 200, 200);
    self.linkTextColor = RGBCOLOR(87, 107, 149);
    self.moreLinkTextColor = RGBCOLOR(36, 112, 216);
    self.tableActivityTextColor = RGBCOLOR(99, 109, 125);
    self.tableErrorTextColor = RGBCOLOR(99, 109, 125);
    self.tableSubTextColor = RGBCOLOR(99, 109, 125);
    self.tableTitleTextColor = RGBCOLOR(99, 109, 125);
    self.placeholderTextColor = RGBCOLOR(180, 180, 180);
    self.searchTableBackgroundColor = RGBCOLOR(235, 235, 235);
    self.searchTableSeparatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    
    _styleSheets = [[NSMutableArray alloc] init];
    _styles = [[NSMutableDictionary alloc] init];
    
    _tableHeaderTextColor = nil;
    _tableHeaderShadowColor = nil;
    _tableHeaderTintColor = nil;

    _linkStyle = nil;
    _linkHighlightedStyle = nil;
    _searchTextFieldStyle = nil;
    _searchBarStyle = nil;
    _tableHeaderStyle = nil;
    _pickerCellStyle = nil;
    _pickerCellSelectedStyle = nil;
    _searchTableShadowStyle = nil;
    _blackBezelStyle = nil;
    _whiteBezelStyle = nil;
  }
  return self;
}

- (void)dealloc {
  [_styleSheets release];
  [_styles release];
  
  [_navigationBarTintColor release];
  [_toolbarTintColor release];
  [_searchBarTintColor release];
  [_linkTextColor release];
  [_moreLinkTextColor release];
  [_tableActivityTextColor release];
  [_tableErrorTextColor release];
  [_tableSubTextColor release];
  [_tableTitleTextColor release];
  [_placeholderTextColor release];
  [_searchTableBackgroundColor release];
  [_searchTableSeparatorColor release];
  [_tableHeaderTextColor release];
  [_tableHeaderShadowColor release];
  [_tableHeaderTintColor release];

  [_linkStyle release];
  [_linkHighlightedStyle release];
  [_searchTextFieldStyle release];
  [_searchBarStyle release];
  [_tableHeaderStyle release];
  [_pickerCellStyle release];
  [_pickerCellSelectedStyle release];
  [_searchTableShadowStyle release];
  [_blackBezelStyle release];
  [_whiteBezelStyle release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTStyle*)linkStyle {
  if (!_linkStyle) {
    _linkStyle = [[TTTextStyle styleWithColor:self.linkTextColor next:nil] retain];
  }
  return _linkStyle;
}

- (TTStyle*)linkHighlightedStyle {
  if (!_linkHighlightedStyle) {
    _linkHighlightedStyle =
      [[TTInsetStyle styleWithInset:UIEdgeInsetsMake(-3, -4, -3, -4) next:
      [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:4.5] next:
      [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.25] next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(3, 4, 3, 4) next:
      [TTTextStyle styleWithColor:self.linkTextColor next:nil]]]]] retain];
  }
  return _linkHighlightedStyle;
}

- (TTStyle*)searchTextFieldStyle {
  if (!_searchTextFieldStyle) {
    _searchTextFieldStyle =
      [[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:13] next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 2, 0) next:
      [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.6) blur:0 offset:CGSizeMake(0, 1) next:
      [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
      [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
      [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
                       width:1 lightSource:270 next:nil]]]]]] retain];
  }
  return _searchTextFieldStyle;
}


- (TTStyle*)searchBarStyle {
  if (!_searchBarStyle) {
    UIColor* highlight = [self.searchBarTintColor multiplyHue:0 saturation:0 value:1.2];
    UIColor* shadow = [self.searchBarTintColor multiplyHue:0 saturation:0 value:0.82];
    _searchBarStyle =
      [[TTLinearGradientFillStyle styleWithColor1:highlight
                                 color2:self.searchBarTintColor next:
      [TTFourBorderStyle styleWithTop:nil right:nil bottom:shadow left:nil width:1 next:nil]]
        retain];
  }
  return _searchBarStyle;
}

- (TTStyle*)tableHeaderStyle {
  if (!_tableHeaderStyle) {
    _tableHeaderStyle =
      [[TTReflectiveFillStyle styleWithColor:self.tableHeaderTintColor next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, 0, 0, 0) next:
      [TTFourBorderStyle styleWithTop:nil right:nil bottom:RGBACOLOR(0,0,0,0.15)
                         left:nil width:1 next:nil]]] retain];
  }
  return _tableHeaderStyle;
}

- (TTStyle*)pickerCellStyle {
  if (!_pickerCellStyle) {
    _pickerCellStyle =
     [[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
     [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(221, 231, 248)
                                  color2:RGBACOLOR(188, 206, 241, 1) next:
      [TTFourBorderStyle styleWithTop:RGBCOLOR(161, 187, 283)
                         right:RGBCOLOR(118, 130, 214) bottom:RGBCOLOR(118, 130, 214)
                         left:RGBCOLOR(161, 187, 283) width:1 next:nil]]]] retain];
  }
  return _pickerCellStyle;
}

- (TTStyle*)pickerCellSelectedStyle {
  if (!_pickerCellSelectedStyle) {
    _pickerCellSelectedStyle =
      [[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
      [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(79, 144, 255)
                                 color2:RGBCOLOR(49, 90, 255) next:
      [TTFourBorderStyle styleWithTop:RGBCOLOR(53, 94, 255)
                         right:RGBCOLOR(53, 94, 255) bottom:RGBCOLOR(53, 94, 255)
                         left:RGBCOLOR(53, 94, 255) width:1 next:nil]]]] retain];
  }
  return _pickerCellSelectedStyle;
}

- (TTStyle*)searchTableShadowStyle {
  if (!_searchTableShadowStyle) {
    _searchTableShadowStyle =
      [[TTLinearGradientFillStyle styleWithColor1:RGBACOLOR(0, 0, 0, 0.18)
                                 color2:[UIColor clearColor] next:
      [TTFourBorderStyle styleWithTop:RGBCOLOR(130, 130, 130) right:nil bottom:nil left:nil
                         width:1 next:nil]] retain];
  }
  return _searchTableShadowStyle;
}

- (TTStyle*)blackBezelStyle {
  if (!_blackBezelStyle) {
    _blackBezelStyle =
      [[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
      [TTSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.7) next:nil]] retain];
  }
  return _blackBezelStyle;
}

- (TTStyle*)whiteBezelStyle {
  if (!_whiteBezelStyle) {
    _whiteBezelStyle =
      [[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
      [TTSolidFillStyle styleWithColor:RGBCOLOR(255, 255, 255) next:
      [TTSolidBorderStyle styleWithColor:RGBCOLOR(178, 178, 178) width:1 next:nil]]] retain];
  }
  return _whiteBezelStyle;
}

- (void)addStyleSheet:(Class)styleSheet {
  [_styleSheets addObject:styleSheet];
}

- (void)removeStyleSheet:(Class)styleSheet {
  [_styleSheets removeObject:styleSheet];
}

- (TTStyle*)styleWithClassName:(NSString*)className {
  return [self styleWithClassName:className forState:UIControlStateNormal];
}

- (TTStyle*)styleWithClassName:(NSString*)className forState:(UIControlState)state {
  NSString* key = state == UIControlStateNormal
    ? className
    : [NSString stringWithFormat:@"%@%d", className, state];
  TTStyle* style = [_styles objectForKey:key];
  if (!style) {
    SEL selector = NSSelectorFromString(className);
    for (Class styleSheet in _styleSheets) {
      if ([styleSheet respondsToSelector:selector]) {
        style = [styleSheet performSelector:selector withObject:(id)state];
        if (style) {
          [_styles setObject:style forKey:key];
          break;
        }
      }
    }
  }
  return style;
}

@end
