#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIFont (TTCategory)

- (CGFloat)lineHeight {
  return (self.ascender - self.descender)+1;
}

@end
