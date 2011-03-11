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

#import "Three20UI/TTTableViewDelegate.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTTableViewDataSource.h"
#import "Three20UI/TTTableViewController.h"
#import "Three20UI/TTTableHeaderView.h"
#import "Three20UI/TTTableView.h"
#import "Three20UI/TTStyledTextLabel.h"

// - Table Items
#import "Three20UI/TTTableItem.h"
#import "Three20UI/TTTableLinkedItem.h"
#import "Three20UI/TTTableButton.h"
#import "Three20UI/TTTableMoreButton.h"

// - Table Item Cells
#import "Three20UI/TTTableMoreButtonCell.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Network
#import "Three20Network/TTURLRequestQueue.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewDelegate

@synthesize controller = _controller;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(TTTableViewController*)controller {
  if (self = [super init]) {
    _controller = controller;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_headers);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * If tableHeaderTintColor has been specified in the global style sheet and this is a plain table
 * (i.e. not a grouped one), then we create header view objects for each header and handle the
 * drawing ourselves.
 */
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (tableView.style == UITableViewStylePlain && TTSTYLEVAR(tableHeaderTintColor)) {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
      NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
      if (title.length > 0) {
        TTTableHeaderView* header = [_headers objectForKey:title];

        // If retrieved from cache, prepare for reuse here.
        // We reset the the opacity to 1 because UITableView might set this property to 0 after
        // removing it.
        // TODO (jverkoey Feb 26, 2011): When does this happen, exactly?
        if (nil != header) {
          header.alpha = 1;

        } else {
          if (nil == _headers) {
            _headers = [[NSMutableDictionary alloc] init];
          }
          header = [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
          [_headers setObject:header forKey:title];
        }
        return header;
      }
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * When the user taps a cell item, we check whether the tapped item has an attached URL and, if
 * it has one, we navigate to it. This also handles the logic for "Load more" buttons.
 */
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
  id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  if ([object isKindOfClass:[TTTableLinkedItem class]]) {
    TTTableLinkedItem* item = object;
    if (item.URL && [_controller shouldOpenURL:item.URL]) {
      TTOpenURLFromView(item.URL, tableView);

    } else if (item.delegate && item.selector) {
      [item.delegate performSelector:item.selector withObject:object];
    }

    if ([object isKindOfClass:[TTTableButton class]]) {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];

    } else if ([object isKindOfClass:[TTTableMoreButton class]]) {
      TTTableMoreButton* moreLink = (TTTableMoreButton*)object;
      moreLink.isLoading = YES;
      TTTableMoreButtonCell* cell
        = (TTTableMoreButtonCell*)[tableView cellForRowAtIndexPath:indexPath];
      cell.animating = YES;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];

      if (moreLink.model) {
        [moreLink.model load:TTURLRequestCachePolicyDefault more:YES];

      } else {
        [_controller.model load:TTURLRequestCachePolicyDefault more:YES];
      }
    }
  }

  [_controller didSelectObject:object atIndexPath:indexPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Similar logic to the above. If the user taps an accessory item and there is an associated URL,
 * we navigate to that URL.
 */
- (void)tableView:(UITableView*)tableView
        accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
  id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  if ([object isKindOfClass:[TTTableLinkedItem class]]) {
    TTTableLinkedItem* item = object;
    if (item.accessoryURL && [_controller shouldOpenURL:item.accessoryURL]) {
      TTOpenURLFromView(item.accessoryURL, tableView);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_controller.menuView) {
    [_controller hideMenu:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;

  [_controller didBeginDragging];

  if ([scrollView isKindOfClass:[TTTableView class]]) {
    TTTableView* tableView = (TTTableView*)scrollView;
    tableView.highlightedLabel.highlightedNode = nil;
    tableView.highlightedLabel = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [TTURLRequestQueue mainQueue].suspended = NO;
  }

  [_controller didEndDragging];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  if (_controller.menuView) {
    [_controller hideMenu:YES];
  }
}


@end
