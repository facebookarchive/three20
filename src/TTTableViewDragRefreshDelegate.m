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

#import "Three20/TTTableViewDragRefreshDelegate.h"

#import "Three20/TTTableHeaderDragRefreshView.h"

#import "Three20/TTTableViewController.h"

#import "Three20/TTGlobalUI.h"
#import "Three20/TTGlobalStyle.h"
#import "Three20/TTDefaultStyleSheet.h"

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
static const CGFloat kRefreshDeltaY = -65.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewDragRefreshDelegate

@synthesize headerView = _headerView;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(TTTableViewController*)controller {
  if (self = [super initWithController:controller]) {
    // Add our refresh header
    _headerView = [[TTTableHeaderDragRefreshView alloc]
                          initWithFrame:CGRectMake(0,
                                                   -_controller.tableView.bounds.size.height,
                                                   _controller.tableView.width,
                                                   _controller.tableView.bounds.size.height)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
    [_controller.tableView addSubview:_headerView];
    
    // Hook up to the model to listen for changes.
    [controller.model.delegates addObject:self];
    
    // Grab the last refresh date if there is one.
    if ([_controller.model respondsToSelector:@selector(loadedTime)]) {
      NSDate* date = [_controller.model performSelector:@selector(loadedTime)];
      
      if (nil != date) {
        [_headerView setUpdateDate:date];
      }
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_controller.model.delegates removeObject:self];
  TT_RELEASE_SAFELY(_headerView);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  [super scrollViewDidScroll:scrollView];
  
  if (_isDragging) {
    if (_headerView.isFlipped
        && scrollView.contentOffset.y > kRefreshDeltaY
        && scrollView.contentOffset.y < 0.0f
        && !_controller.model.isLoading) {
      [_headerView flipImageAnimated:YES];
      [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
      
    } else if (!_headerView.isFlipped
               && scrollView.contentOffset.y < kRefreshDeltaY) {
      [_headerView flipImageAnimated:YES];
      [_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
  [super scrollViewWillBeginDragging:scrollView];
  
  _isDragging = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
  [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  
  // If dragging ends and we are far enough to be fully showing the header view trigger a
  // load as long as we arent loading already
  if (scrollView.contentOffset.y <= kRefreshDeltaY && !_controller.model.isLoading) {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"DragRefreshTableReload" object:nil];
    [_controller.model load:TTURLRequestCachePolicyNetwork more:NO];
  }
  
  _isDragging = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<TTModel>)model {
  [_headerView showActivity:YES];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
  _controller.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 00.0f, 0.0f);
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
  [_headerView flipImageAnimated:NO];
  [_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
  [_headerView showActivity:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:ttkDefaultTransitionDuration];
  _controller.tableView.contentInset = UIEdgeInsetsZero;
  [UIView commitAnimations];
  
  if ([model respondsToSelector:@selector(loadedTime)]) {
    NSDate* date = [model performSelector:@selector(loadedTime)];
    [_headerView setUpdateDate:date];
    
  } else {
    [_headerView setCurrentDate];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  [_headerView flipImageAnimated:NO];
  [_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
  [_headerView showActivity:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:ttkDefaultTransitionDuration];
  _controller.tableView.contentInset = UIEdgeInsetsZero;
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
  [_headerView flipImageAnimated:NO];
  [_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
  [_headerView showActivity:NO];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:ttkDefaultTransitionDuration];
  _controller.tableView.contentInset = UIEdgeInsetsZero;
  [UIView commitAnimations];
}


@end
