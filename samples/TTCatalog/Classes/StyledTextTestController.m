#import "StyledTextTestController.h"

@implementation StyledTextTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  NSString* kSampleText = @"This is a test of http://foo.com styled text. This test will \
be more interesting when I implement the HTML parser.  See the 'Styled Labels in Table' test \
for another example of styled text.  Gratuitous URL alert: http://www.foo.com";

  TTStyledLabel* label = [[[TTStyledLabel alloc] initWithFrame:
                            CGRectInset(self.view.bounds, 10, 10)] autorelease];
  label.font = [UIFont systemFontOfSize:18];
  label.text = [TTStyledText textFromURLString:kSampleText];
   
  [self.view addSubview:label];
}

@end
