#import "StyledTextTestController.h"

@implementation StyledTextTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  NSString* kText = @"This is a test of styled labels. Styled labels support \
<b>bold text</b> and <i>italic text</i>. They also support \
<a href=\"http://www.google.com\">hyperlinks</a> and inline images \
<img src=\"bundle://smiley.png\"/>. You can also embed a URL inline and it will be turned into \
a link, like the following URL: http://www.foo.com";

  TTStyledLabel* label1 = [[[TTStyledLabel alloc] initWithFrame:
                            CGRectInset(self.view.bounds, 10, 10)] autorelease];
  label1.font = [UIFont systemFontOfSize:17];
  label1.text = [TTStyledText textFromXHTML:kText];
  [label1 sizeToFit];
  [self.view addSubview:label1];

  TTStyledLabel* label2 = [[[TTStyledLabel alloc] initWithFrame:
                            CGRectInset(self.view.bounds, 10, 10)] autorelease];
  label2.font = [UIFont systemFontOfSize:12];
  label2.text = [TTStyledText textFromXHTML:kText];
  label2.textColor = [UIColor grayColor];
  [label2 sizeToFit];
  label2.top = label1.bottom + 20;
  [self.view addSubview:label2];
}

@end
  