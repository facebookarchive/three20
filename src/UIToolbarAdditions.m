#import "Three20/TTGlobal.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIToolbar (TTCategory)

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag {
  for (UIBarButtonItem* button in self.items) {
    if (button.tag == tag) {
      return button;
    }
  }
  return nil;  
}

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item {
  NSInteger index = 0;
  for (UIBarButtonItem* button in self.items) {
    if (button.tag == tag) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.items];
      [newItems replaceObjectAtIndex:index withObject:item];
      self.items = newItems;
      break;
    }
    ++index;
  }
  
}

@end
