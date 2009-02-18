
#import "MockDataSource.h"

@implementation MockDataSource

- (id)init {
  if (self = [super init]) {
    _allItems = [[NSMutableArray alloc] initWithObjects:
      [[[TTTableField alloc] initWithText:@"Robert Anderson" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Jim James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Ed James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Fred James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Martha James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Ted James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Ned James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Jed James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Bert James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Ernie James" href:TT_NULL_URL] autorelease],
      [[[TTTableField alloc] initWithText:@"Sean James" href:TT_NULL_URL] autorelease],
      nil];
  }
  return self;
}

- (void)dealloc {
  [_allItems release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (NSMutableArray*)delegates {
  return [super delegates];
}

@end
