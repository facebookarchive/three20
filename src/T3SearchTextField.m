#import "Three20/T3SearchTextField.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3SearchTextField

@synthesize searchSource = _searchSource;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _searchSource = nil;
  }
  return self;
}

- (void)dealloc {
  [_searchSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextField

- (void)setText:(NSString*)text {
  if (_searchSource) {
//    [self updateHeight];
  }

  [super setText:text];

  if (_searchSource) {
//    [_searchSource update:self string:text];
  }
}

@end
