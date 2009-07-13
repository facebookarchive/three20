#import "Three20/TTTableViewDataSource.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTTableItemCell.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTTextEditor.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableViewDataSource

@synthesize delegates = _delegates;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegates = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_delegates);
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
  
  [self tableView:tableView prepareCell:cell forRowAtIndexPath:indexPath];
      
  return cell;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return nil;
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (NSDate*)loadedTime {
  id<TTLoadable> loadable = self.loadable;
  if (loadable) {
    return loadable.loadedTime;
  } else {
    return nil;
  }
}

- (BOOL)isLoading {
  id<TTLoadable> loadable = self.loadable;
  if (loadable) {
    return loadable.isLoading;
  } else {
    return NO;
  }
}

- (BOOL)isLoadingMore {
  id<TTLoadable> loadable = self.loadable;
  if (loadable) {
    return loadable.isLoadingMore;
  } else {
    return NO;
  }
}

- (BOOL)isLoaded {
  id<TTLoadable> loadable = self.loadable;
  if (loadable) {
    return loadable.isLoaded;
  } else {
    return YES;
  }
}

- (BOOL)isOutdated {
  id<TTLoadable> loadable = self.loadable;
  if (loadable) {
    return loadable.isOutdated;
  } else {
    NSDate* loadedTime = self.loadedTime;
    if (loadedTime) {
      return -[loadedTime timeIntervalSinceNow] > [TTURLCache sharedCache].invalidationAge;
    } else {
      return NO;
    }
  }
}

- (BOOL)isEmpty {
  id<TTLoadable> loadable = self.loadable;
  if (loadable) {
    return loadable.isEmpty;
  } else {
    return YES;
  }
}

- (void)invalidate:(BOOL)erase {
  [self.loadable invalidate:erase];
}

- (void)cancel {
  [self.loadable cancel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

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

- (void)tableView:(UITableView*)tableView prepareCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath {
}

- (void)tableView:(UITableView*)tableView search:(NSString*)text {
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy nextPage:(BOOL)nextPage {
}

- (void)rebuild {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadableDelegate

- (void)loadableDidStartLoad:(id<TTLoadable>)loadable {
  [self didStartLoad];
}

- (void)loadableDidFinishLoad:(id<TTLoadable>)loadable {
  [self rebuild];
  [self didFinishLoad];
}

- (void)loadable:(id<TTLoadable>)loadable didFailLoadWithError:(NSError*)error {
  [self didFailLoadWithError:error];
}

- (void)loadableDidCancelLoad:(id<TTLoadable>)loadable {
  [self didCancelLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id<TTLoadable>)loadable {
  return nil;
}

- (void)didStartLoad {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSourceDidStartLoad:)]) {
      [delegate dataSourceDidStartLoad:self];
    }
  }
}

- (void)didFinishLoad {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSourceDidFinishLoad:)]) {
      [delegate dataSourceDidFinishLoad:self];
    }
  }
}

- (void)didFailLoadWithError:(NSError*)error {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSource:didFailLoadWithError:)]) {
      [delegate dataSource:self didFailLoadWithError:error];
    }
  }
}

- (void)didCancelLoad {
  for (id<TTTableViewDataSourceDelegate> delegate in self.delegates) {
    if ([delegate respondsToSelector:@selector(dataSourceDidCancelLoad:)]) {
      [delegate dataSourceDidCancelLoad:self];
    }
  }
}

@end
