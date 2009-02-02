#import "Three20/T3Global.h"

@implementation UITableView (T3Category)

- (UIView*)indexView {
  Class indexViewClass = NSClassFromString(@"UITableViewIndex");
  NSEnumerator* e = [self.subviews reverseObjectEnumerator];
  for (UIView* child; child = [e nextObject]; ) {
    if ([child isKindOfClass:indexViewClass]) {
      return child;
    }
  }
  return nil;
}

@end
