#import "ButtonTestController.h"
#import <Three20UI/UIViewAdditions.h>

@interface ButtonTestStyleSheet : TTDefaultStyleSheet
@end

@implementation ButtonTestStyleSheet

- (TTStyle*)blackForwardButton:(UIControlState)state {
  TTShape* shape = [TTRoundedRightArrowShape shapeWithRadius:4.5];
  UIColor* tintColor = RGBCOLOR(0, 0, 0);
  return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}

- (TTStyle*)blueToolbarButton:(UIControlState)state {
  TTShape* shape = [TTRoundedRectangleShape shapeWithRadius:4.5];
  UIColor* tintColor = RGBCOLOR(30, 110, 255);
  return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}

- (TTStyle*)embossedButton:(UIControlState)state {
  if (state == UIControlStateNormal) {
  return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
    [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
    [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
                               color2:RGBCOLOR(216, 221, 231) next:
    [TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
    [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
    [TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
                 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else if (state == UIControlStateHighlighted) {
    return
      [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
      [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
      [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
                                 color2:RGBCOLOR(196, 201, 221) next:
      [TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
      [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
      [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
                   shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else {
    return nil;
  }
}

- (TTStyle*)dropButton:(UIControlState)state {
  if (state == UIControlStateNormal) {
    return
      [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
      [TTShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.7) blur:3 offset:CGSizeMake(2, 2) next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0.25, 0.25, 0.25, 0.25) next:
      [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-0.25, -0.25, -0.25, -0.25) next:
      [TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 0, 0) next:
      [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(11, 10, 9, 10) next:
      [TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
                   shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]]];
  } else if (state == UIControlStateHighlighted) {
    return
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(3, 3, 0, 0) next:
      [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
      [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
      [TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
      [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 0, 0) next:
      [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(11, 10, 9, 10) next:
      [TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
                   shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else {
    return nil;
  }
}

@end

@implementation ButtonTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)layout {
  TTFlowLayout* flowLayout = [[[TTFlowLayout alloc] init] autorelease];
  flowLayout.padding = 20;
  flowLayout.spacing = 20;
  CGSize size = [flowLayout layoutSubviews:self.view.subviews forView:self.view];

  UIScrollView* scrollView = (UIScrollView*)self.view;
  scrollView.contentSize = CGSizeMake(scrollView.width, size.height);
}

- (void)increaseFont {
  _fontSize += 4;

  for (UIView* view in self.view.subviews) {
    if ([view isKindOfClass:[TTButton class]]) {
      TTButton* button = (TTButton*)view;
      button.font = [UIFont boldSystemFontOfSize:_fontSize];
      [button sizeToFit];
    }
  }
  [self layout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _fontSize = 12;

    [TTStyleSheet setGlobalStyleSheet:[[[ButtonTestStyleSheet alloc] init] autorelease]];
  }
  return self;
}

- (void)dealloc {
  [TTStyleSheet setGlobalStyleSheet:nil];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  self.navigationItem.rightBarButtonItem
    = [[[UIBarButtonItem alloc] initWithTitle:@"Increase Font" style:UIBarButtonItemStyleBordered
                                target:self action:@selector(increaseFont)] autorelease];

  UIScrollView* scrollView = [[[UIScrollView alloc] initWithFrame:TTNavigationFrame()] autorelease];
	scrollView.autoresizesSubviews = YES;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.backgroundColor = RGBCOLOR(216, 221, 231);
  //scrollView.backgroundColor = RGBCOLOR(119, 140, 168);
  scrollView.canCancelContentTouches = NO;
  scrollView.delaysContentTouches = NO;
  self.view = scrollView;

  NSArray* buttons = [NSArray arrayWithObjects:
    [TTButton buttonWithStyle:@"toolbarButton:" title:@"Toolbar Button"],
    [TTButton buttonWithStyle:@"toolbarRoundButton:" title:@"Round Button"],
    [TTButton buttonWithStyle:@"toolbarBackButton:" title:@"Back Button"],
    [TTButton buttonWithStyle:@"toolbarForwardButton:" title:@"Forward Button"],

    [TTButton buttonWithStyle:@"blackForwardButton:" title:@"Black Button"],
    [TTButton buttonWithStyle:@"blueToolbarButton:" title:@"Blue Button"],
    [TTButton buttonWithStyle:@"embossedButton:" title:@"Embossed Button"],
    [TTButton buttonWithStyle:@"dropButton:" title:@"Shadow Button"],
    nil];

  for (TTButton* button in buttons) {
    button.font = [UIFont boldSystemFontOfSize:_fontSize];
    [button sizeToFit];
    [scrollView addSubview:button];
  }

  [self layout];
}

@end
