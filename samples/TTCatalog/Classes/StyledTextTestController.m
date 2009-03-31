#import "StyledTextTestController.h"

@implementation StyledTextTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  NSString* kSampleText = @"This is a test of http://foo.com styled text. This test will \
be more interesting when I implement the HTML parser.  See the 'Styled Labels in Table' test \
for another example of styled text.  Gratuitous URL alert: http://www.foo.com";

  CGRect bounds = CGRectInset(self.view.bounds, 10, 10);
  TTStyledLabel* label = [[[TTStyledLabel alloc] initWithFrame:bounds] autorelease];
  label.font = [UIFont systemFontOfSize:19];
  label.text = [TTStyledText textFromURLString:kSampleText];
   
  [self.view addSubview:label];
}

@end
