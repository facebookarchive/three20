#import "Three20/TTTableViewDataSource.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTTableItemCell.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTTextEditor.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewDataSource

@synthesize model = _model;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _model = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_model);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];

  Class cellClass = [self tableView:tableView cellClassForObject:object];
  const char* className = class_getName(cellClass);
  NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                           length:strlen(className)
                                           encoding:NSASCIIStringEncoding freeWhenDone:NO];

  UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:identifier] autorelease];
  }
  [identifier release];
  
  if ([cell isKindOfClass:[TTTableViewCell class]]) {
    [(TTTableViewCell*)cell setObject:object];
  }
  
  [self tableView:tableView cell:cell willAppearAtIndexPath:indexPath];
      
  return cell;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (id<TTModel>)model {
  return _model;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[TTTableItem class]]) {
    if ([object isKindOfClass:[TTTableMoreButton class]]) {
      return [TTTableMoreButtonCell class];
    } else if ([object isKindOfClass:[TTTableCaptionedItem class]]) {
      return [TTTableCaptionedItemCell class];
    } else if ([object isKindOfClass:[TTTableImageItem class]]) {
      return [TTTableImageItemCell class];
    } else if ([object isKindOfClass:[TTTableStyledTextItem class]]) {
      return [TTStyledTextTableItemCell class];
    } else if ([object isKindOfClass:[TTTableActivityItem class]]) {
      return [TTTableActivityItemCell class];
    } else if ([object isKindOfClass:[TTTableErrorItem class]]) {
      return [TTTableErrorItemCell class];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
      return [TTTableControlCell class];
    } else {
      return [TTTableTextItemCell class];
    }
  } else if ([object isKindOfClass:[UIControl class]]
             || [object isKindOfClass:[UITextView class]]
             || [object isKindOfClass:[TTTextEditor class]]) {
    return [TTTableControlCell class];
  } else if ([object isKindOfClass:[UIView class]]) {
    return [TTTableFlushViewCell class];
  }
  
  // This will display an empty white table cell - probably not what you want, but it
  // is better than crashing, which is what happens if you return nil here
  return [TTTableViewCell class];
}

- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object {
  return [NSString stringWithFormat:@"%@", object];
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  return nil;
}

- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
        willAppearAtIndexPath:(NSIndexPath*)indexPath {
}

- (void)willAppearInTableView:(UITableView*)tableView {
}

- (void)search:(NSString*)text {
}

- (NSString*)titleForLoading:(BOOL)refreshing {
  if (refreshing) {
    return TTLocalizedString(@"Updating...", @"");
  } else {
    return TTLocalizedString(@"Loading...", @"");
  }
}

- (UIImage*)imageForNoData {
  return nil;
}

- (NSString*)titleForNoData {
  return nil;
}

- (NSString*)subtitleForNoData {
  return nil;
}

- (UIImage*)imageForError:(NSError*)error {
  return nil;
}

- (NSString*)titleForError:(NSError*)error {
  return TTLocalizedString(@"Error", @"");
}

- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"Sorry, an error has occurred.", @"");
}

@end
