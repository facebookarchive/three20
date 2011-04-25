//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/UITableViewAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

// UI
#import "Three20UI/UIViewAdditions.h"

// UICommon
#import "Three20UICommon/UIWindowAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UITableViewAdditions)

@implementation UITableView (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableCellMargin {
  if (self.style == UITableViewStyleGrouped) {
    return 10;

  } else {
    return 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToTop:(BOOL)animated {
  [self setContentOffset:CGPointMake(0,0) animated:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToFirstRow:(BOOL)animated {
  if ([self numberOfSections] > 0 && [self numberOfRowsInSection:0] > 0) {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop
          animated:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToLastRow:(BOOL)animated {
  if ([self numberOfSections] > 0) {
    NSInteger section = [self numberOfSections]-1;
    NSInteger rowCount = [self numberOfRowsInSection:section];
    if (rowCount > 0) {
      NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:section];
      [self scrollToRowAtIndexPath:indexPath
                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollFirstResponderIntoView {
  UIView* responder = [self.window findFirstResponder];
  UITableViewCell* cell = (UITableViewCell*)[responder
                                             ancestorOrSelfWithClass:[UITableViewCell class]];
  if (cell) {
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    if (indexPath) {
      [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle
            animated:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


@end
