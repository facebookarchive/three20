
#import "TestSearchSource.h"

@implementation TestSearchSource

- (void)textField:(TTSearchTextField*)textField searchForText:(NSString*)text {
//  _items = [[NSMutableArray alloc] initWithObjects:
//    [[[TTActivityTableField alloc] initWithText:@"Searching..."] autorelease],
//    nil];

  [_items release];

  if (text.length) {
    _items = [[NSMutableArray alloc] initWithObjects:
      [[[TTTableField alloc] initWithText:@"Robert Anderson" href:@"fb://x"] autorelease],
      [[[TTTableField alloc] initWithText:@"Jim James" href:@"fb://x"] autorelease],
      nil];
  } else {
    _items = nil;
  }
  [textField updateResults];
}

- (NSString*)textField:(TTSearchTextField*)textField
    labelForRowAtIndexPath:(NSIndexPath*)indexPath {
  TTTableField* field = [self objectForRowAtIndexPath:indexPath];
  return field.text;
}

@end
