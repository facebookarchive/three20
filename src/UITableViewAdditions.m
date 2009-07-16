#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITableView (TTCategory)

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

- (void)scrollToTop:(BOOL)animated {
  [self setContentOffset:CGPointMake(0,0) animated:animated];
}

- (void)scrollToBottom:(BOOL)animated {
  NSUInteger sectionCount = [self numberOfSections];
  if (sectionCount) {
    NSUInteger rowCount = [self numberOfRowsInSection:0];
    if (rowCount) {
      NSUInteger ii[2] = {0, rowCount-1};
      NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
      [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom
        animated:animated];
    }
  }
}

- (void)touchRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
  if (![self cellForRowAtIndexPath:indexPath]) {
    [self reloadData];
  }
  
  if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
    [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
  }

  [self selectRowAtIndexPath:indexPath animated:animated
    scrollPosition:UITableViewScrollPositionTop];

  if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
    [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
  }
}

- (void)scrollFirstResponderIntoView {
  UIView* responder = [self.window performSelector:@selector(firstResponder)];
  UITableViewCell* cell = (UITableViewCell*)[responder ancestorOrSelfWithClass:[UITableViewCell class]];
  if (cell) {
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    if (indexPath) {
      [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
            animated:YES];
    }
  }
}

@end
