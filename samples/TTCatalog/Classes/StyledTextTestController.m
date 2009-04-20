#import "StyledTextTestController.h"

@interface TextTestStyleSheet : TTDefaultStyleSheet
@end

@implementation TextTestStyleSheet

- (TTStyle*)blueText {
  return [TTTextStyle styleWithColor:[UIColor blueColor] next:nil];
}

- (TTStyle*)largeText {
  return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:32] next:nil];
}

- (TTStyle*)blueBox {
  return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
    [TTShadowStyle styleWithColor:[UIColor grayColor] blur:2 offset:CGSizeMake(1,1) next:
    [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
    [TTSolidBorderStyle styleWithColor:[UIColor grayColor] width:1 next:nil]]]]];
}

- (TTStyle*)inlineBox {
  return 
    [TTSolidFillStyle styleWithColor:[UIColor blueColor] next:
    [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(5,13,5,13) next:
    [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:nil]]];
}

- (TTStyle*)inlineBox2 {
  return 
    [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
    [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(5,50,0,50)
                padding:UIEdgeInsetsMake(0,13,0,13) next:nil]];
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
  
  NSString* kText = @"\
This is a test of styled labels.  Styled labels support \
<b>bold text</b>, <i>italic text</i>, <span class=\"blueText\">colored text</span>, \
<span class=\"largeText\">font sizes</span>, \
<span class=\"blueBox\">spans with backgrounds</span>, inline images \
<img src=\"bundle://smiley.png\"/>, and <a href=\"http://www.google.com\">hyperlinks</a> you can \
actually touch. URLs are automatically converted into links, like this: http://www.foo.com\
<div class=\"blueBox\">You can enclose blocks within an HTML div.</div>\
Both line break characters\n\nand HTML line breaks<br/>are respected.";
//  NSString* kText = @"<span class=\"largeText\">bah</span><span class=\"inlineBox\">hyper links</span>";
//  NSString* kText = @"blah blah blah black sheep blah <span class=\"inlineBox\">\
//<img src=\"bundle://smiley.png\"/>hyperlinks</span> blah fun";
//  NSString* kText = @"\
//<div class=\"inlineBox\"><div class=\"inlineBox2\">You can enclose blocks within an HTML div.</div></div>";
//  NSString* kText = @"\
//<span class=\"inlineBox\"><span class=\"inlineBox2\">You can enclose blocks within an HTML div.</span></span>x";
//  NSString* kText = @"\
//<div class=\"inlineBox2\">You can enclose blocks within an HTML div.</div>";

  TTStyledTextLabel* label1 = [[[TTStyledTextLabel alloc] initWithFrame:self.view.bounds] autorelease];
  label1.font = [UIFont systemFontOfSize:17];
  label1.text = [TTStyledText textFromXHTML:kText lineBreaks:YES urls:YES];
  label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
  //label1.backgroundColor = [UIColor grayColor];
  [label1 sizeToFit];
  [self.view addSubview:label1];
}

@end
  