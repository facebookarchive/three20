//
// Copyright 2009-2010 Facebook
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

#import "Three20UI/TTTableViewDataSource.h"

// UI
#import "Three20UI/TTTextEditor.h"

// - Table Items
#import "Three20UI/TTTableItem.h"
#import "Three20UI/TTTableMoreButton.h"
#import "Three20UI/TTTableSubtextItem.h"
#import "Three20UI/TTTableRightCaptionItem.h"
#import "Three20UI/TTTableCaptionItem.h"
#import "Three20UI/TTTableSubtitleItem.h"
#import "Three20UI/TTTableMessageItem.h"
#import "Three20UI/TTTableImageItem.h"
#import "Three20UI/TTTableStyledTextItem.h"
#import "Three20UI/TTTableTextItem.h"
#import "Three20UI/TTTableActivityItem.h"
#import "Three20UI/TTTableControlItem.h"

// - Table Cells
#import "Three20UI/TTTableMoreButtonCell.h"
#import "Three20UI/TTTableSubtextItemCell.h"
#import "Three20UI/TTTableRightCaptionItemCell.h"
#import "Three20UI/TTTableCaptionItemCell.h"
#import "Three20UI/TTTableSubtitleItemCell.h"
#import "Three20UI/TTTableMessageItemCell.h"
#import "Three20UI/TTTableImageItemCell.h"
#import "Three20UI/TTStyledTextTableItemCell.h"
#import "Three20UI/TTTableActivityItemCell.h"
#import "Three20UI/TTTableControlCell.h"
#import "Three20UI/TTTableTextItemCell.h"
#import "Three20UI/TTStyledTextTableCell.h"
#import "Three20UI/TTTableFlushViewCell.h"

// Style
#import "Three20Style/TTStyledText.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"

#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewDataSource

@synthesize model = _model;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_model);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSArray*)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary {
  NSMutableArray* titles = [NSMutableArray array];
  if (search) {
    [titles addObject:UITableViewIndexSearch];
  }

  for (unichar c = 'A'; c <= 'Z'; ++c) {
    NSString* letter = [NSString stringWithFormat:@"%c", c];
    [titles addObject:letter];
  }

  if (summary) {
    [titles addObject:@"#"];
  }

  return titles;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title
            atIndex:(NSInteger)sectionIndex {
  if (tableView.tableHeaderView) {
    if (sectionIndex == 0)  {
      // This is a hack to get the table header to appear when the user touches the
      // first row in the section index.  By default, it shows the first row, which is
      // not usually what you want.
      [tableView scrollRectToVisible:tableView.tableHeaderView.bounds animated:NO];
      return -1;
    }
  }

  NSString* letter = [title substringToIndex:1];
  NSInteger sectionCount = [tableView numberOfSections];
  for (NSInteger i = 0; i < sectionCount; ++i) {
    NSString* section  = [tableView.dataSource tableView:tableView titleForHeaderInSection:i];
    if ([section hasPrefix:letter]) {
      return i;
    }
  }
  if (sectionIndex >= sectionCount) {
    return sectionCount-1;
  } else {
    return sectionIndex;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)delegates {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _model ? _model : self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[TTTableItem class]]) {
    if ([object isKindOfClass:[TTTableMoreButton class]]) {
      return [TTTableMoreButtonCell class];
    } else if ([object isKindOfClass:[TTTableSubtextItem class]]) {
      return [TTTableSubtextItemCell class];
    } else if ([object isKindOfClass:[TTTableRightCaptionItem class]]) {
      return [TTTableRightCaptionItemCell class];
    } else if ([object isKindOfClass:[TTTableCaptionItem class]]) {
      return [TTTableCaptionItemCell class];
    } else if ([object isKindOfClass:[TTTableSubtitleItem class]]) {
      return [TTTableSubtitleItemCell class];
    } else if ([object isKindOfClass:[TTTableMessageItem class]]) {
      return [TTTableMessageItemCell class];
    } else if ([object isKindOfClass:[TTTableImageItem class]]) {
      return [TTTableImageItemCell class];
    } else if ([object isKindOfClass:[TTTableStyledTextItem class]]) {
      return [TTStyledTextTableItemCell class];
    } else if ([object isKindOfClass:[TTTableActivityItem class]]) {
      return [TTTableActivityItemCell class];
    } else if ([object isKindOfClass:[TTTableControlItem class]]) {
      return [TTTableControlCell class];
    } else {
      return [TTTableTextItemCell class];
    }
  } else if ([object isKindOfClass:[TTStyledText class]]) {
    return [TTStyledTextTableCell class];
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object {
  if ([object isKindOfClass:[TTTableTextItem class]]) {
    TTTableTextItem* item = object;
    return item.text;
  } else {
    return [NSString stringWithFormat:@"%@", object];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
        willAppearAtIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search:(NSString*)text {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return TTLocalizedString(@"Updating...", @"");
  } else {
    return TTLocalizedString(@"Loading...", @"");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForEmpty {
  return [self imageForError:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForEmpty {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForError:(NSError*)error {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError:(NSError*)error {
  return TTDescriptionForError(error);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"Sorry, there was an error.", @"");
}


@end


#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewInterstitialDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)delegates {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
}


@end
