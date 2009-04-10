#import "StyledTextTestController.h"

@interface TextTestStyleSheet : TTDefaultStyleSheet
@end

@implementation TextTestStyleSheet

- (TTStyle*)blueText {
  return [TTTextStyle styleWithColor:[UIColor blueColor] next:nil];
}

- (TTStyle*)blueBox {
  return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, -5, 0, -5) next:
    [TTShadowStyle styleWithColor:[UIColor grayColor] blur:2 offset:CGSizeMake(1,1) next:
    [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
    [TTSolidBorderStyle styleWithColor:[UIColor grayColor] width:1 next:nil]]]]];
}

@end

@implementation StyledTextTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    [TTStyleSheet setGlobalStyleSheet:[[[TextTestStyleSheet alloc] init] autorelease]];
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
  [super loadView];
  
  NSString* kText = @"This is a test of styled labels.  Styled labels support \
<b>bold text</b>, <i>italic text</i>, <span class=\"blueText\">colored text</span>, \
<span class=\"blueBox\">spans with backgrounds</span>, inline images \
<img src=\"bundle://smiley.png\"/>, and <a href=\"http://www.google.com\">hyperlinks</a> you can \
actually touch. URLs are automatically converted into links, like this: http://www.foo.com";

  TTStyledTextLabel* label1 = [[[TTStyledTextLabel alloc] initWithFrame:self.view.bounds] autorelease];
  label1.font = [UIFont systemFontOfSize:17];
  label1.text = [TTStyledText textFromXHTML:kText];
  label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
  [label1 sizeToFit];
  [self.view addSubview:label1];

  TTStyledTextLabel* label2 = [[[TTStyledTextLabel alloc] initWithFrame:self.view.bounds] autorelease];
  label2.font = [UIFont systemFontOfSize:12];
  label2.text = [TTStyledText textFromXHTML:kText];
  label2.textColor = [UIColor grayColor];
  label2.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
  [label2 sizeToFit];
  label2.top = label1.bottom + 20;
  [self.view addSubview:label2];
}

@end
  