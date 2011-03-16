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

#import "Three20UI/TTSearchTextField.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTView.h"
#import "Three20UI/TTSearchTextFieldDelegate.h"
#import "Three20UI/TTTableView.h"
#import "Three20UI/TTTableViewCell.h"
#import "Three20UI/TTTableViewDataSource.h"
#import "Three20UI/UIViewAdditions.h"

// UI (private)
#import "Three20UI/private/TTSearchTextFieldInternal.h"

// UINavigator
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kShadowHeight = 24;
static const CGFloat kDesiredTableHeight = 150;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTSearchTextField

@synthesize tableView             = _tableView;
@synthesize rowHeight             = _rowHeight;
@synthesize searchesAutomatically = _searchesAutomatically;
@synthesize showsDoneButton       = _showsDoneButton;
@synthesize showsDarkScreen       = _showsDarkScreen;
@synthesize dataSource            = _dataSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _internal = [[TTSearchTextFieldInternal alloc] initWithTextField:self];

    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchesAutomatically = YES;

    [self addTarget:self action:@selector(didBeginEditing)
      forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(didEndEditing)
      forControlEvents:UIControlEventEditingDidEnd];

    [super setDelegate:_internal];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_dataSource.model.delegates removeObject:self];
  _tableView.delegate = nil;
  TT_RELEASE_SAFELY(_dataSource);
  TT_RELEASE_SAFELY(_internal);
  TT_RELEASE_SAFELY(_tableView);
  TT_RELEASE_SAFELY(_shadowView);
  TT_RELEASE_SAFELY(_screenView);
  TT_RELEASE_SAFELY(_previousNavigationItem);
  TT_RELEASE_SAFELY(_previousRightBarButtonItem);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showDoneButton:(BOOL)show {
  UIViewController* controller = [TTNavigator navigator].visibleViewController;
  if (controller) {
    if (show) {
      _previousNavigationItem = [controller.navigationItem retain];
      _previousRightBarButtonItem = [controller.navigationItem.rightBarButtonItem retain];

      UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self action:@selector(doneAction)] autorelease];
      [controller.navigationItem setRightBarButtonItem:doneButton animated:YES];

    } else {
      [_previousNavigationItem setRightBarButtonItem:_previousRightBarButtonItem animated:YES];
      TT_RELEASE_SAFELY(_previousRightBarButtonItem);
      TT_RELEASE_SAFELY(_previousNavigationItem);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showDarkScreen:(BOOL)show {
  if (show && !_screenView) {
    _screenView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _screenView.backgroundColor = TTSTYLEVAR(screenBackgroundColor);
    _screenView.frame = [self rectForSearchResults:NO];
    _screenView.alpha = 0;
    [_screenView addTarget:self action:@selector(doneAction)
      forControlEvents:UIControlEventTouchUpInside];
  }

  if (show) {
    [self.superviewForSearchResults addSubview:_screenView];
  }

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(screenAnimationDidStop)];

  _screenView.alpha = show ? 1 : 0;

  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)searchText {
  if (!self.hasText) {
    return @"";

  } else {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
    return [self.text stringByTrimmingCharactersInSet:whitespace];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)autoSearch {
  if (_searchesAutomatically && self.text.length) {
    [self search];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchUpdate:(NSTimer*)timer {
  _searchTimer = nil;
  [self autoSearch];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayedUpdate {
  [_searchTimer invalidate];
  _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
    selector:@selector(dispatchUpdate:) userInfo:nil repeats:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasSearchResults {
  return (![_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]
          || [_dataSource numberOfSectionsInTableView:_tableView])
      && [_dataSource tableView:_tableView numberOfRowsInSection:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadTable {
  [_dataSource tableViewDidLoadModel:self.tableView];

  if ([self hasSearchResults]) {
    [self layoutIfNeeded];
    [self showSearchResults:YES];
    [self.tableView reloadData];

  } else {
    [self showSearchResults:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)screenAnimationDidStop {
  if (_screenView.alpha == 0) {
    [_screenView removeFromSuperview];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)doneAction {
  [self resignFirstResponder];

  if (self.dataSource) {
    self.text = @"";
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITextFieldDelegate>)delegate {
  return _internal.delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  _internal.delegate = delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
  [super setText:text];
  [self autoSearch];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (_rowHeight) {
    return _rowHeight;

  } else {
    id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    Class cls = [_dataSource tableView:tableView cellClassForObject:object];
    return [cls tableView:_tableView rowHeightForObject:object];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if ([_internal.delegate respondsToSelector:@selector(textField:didSelectObject:)]) {
    id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSeparatorStyleNone) {
      [_internal.delegate performSelector:@selector(textField:didSelectObject:) withObject:self
                          withObject:object];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<TTModel>)model {
  if (!_searchesAutomatically) {
    [self reloadTable];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
  [self reloadTable];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidChange:(id<TTModel>)model {
  [self reloadTable];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  [self reloadTable];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControlEvents


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didBeginEditing {
  if (_dataSource) {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    scrollView.scrollEnabled = NO;
    scrollView.scrollsToTop = NO;

    if (_showsDoneButton) {
      [self showDoneButton:YES];
    }
    if (_showsDarkScreen) {
      [self showDarkScreen:YES];
    }
    if (self.hasText && self.hasSearchResults) {
      [self showSearchResults:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didEndEditing {
  if (_dataSource) {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    scrollView.scrollEnabled = YES;
    scrollView.scrollsToTop = YES;

    [self showSearchResults:NO];

    if (_showsDoneButton) {
      [self showDoneButton:NO];
    }
    if (_showsDarkScreen) {
      [self showDarkScreen:NO];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
  if (dataSource != _dataSource) {
    [_dataSource.model.delegates removeObject:self];
    [_dataSource release];
    _dataSource = [dataSource retain];
    [_dataSource.model.delegates addObject:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView*)tableView {
  if (!_tableView) {
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = TTSTYLEVAR(searchTableBackgroundColor);
    _tableView.separatorColor = TTSTYLEVAR(searchTableSeparatorColor);
    _tableView.rowHeight = _rowHeight;
    _tableView.dataSource = _dataSource;
    _tableView.delegate = self;
    _tableView.scrollsToTop = NO;
  }

  return _tableView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSearchesAutomatically:(BOOL)searchesAutomatically {
  _searchesAutomatically = searchesAutomatically;
  if (searchesAutomatically) {
    self.returnKeyType = UIReturnKeyDone;
    self.enablesReturnKeyAutomatically = NO;

  } else {
    self.returnKeyType = UIReturnKeySearch;
    self.enablesReturnKeyAutomatically = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasText {
  return self.text.length;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search {
  if (_dataSource) {
    NSString* text = self.searchText;
    [_dataSource search:text];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSearchResults:(BOOL)show {
  if (show && _dataSource) {
    self.tableView;

    if (!_shadowView) {
      _shadowView = [[TTView alloc] init];
      _shadowView.style = TTSTYLE(searchTableShadow);
      _shadowView.backgroundColor = [UIColor clearColor];
      _shadowView.userInteractionEnabled = NO;
    }

    if (!_tableView.superview) {
      _tableView.frame = [self rectForSearchResults:YES];
      _shadowView.frame = CGRectMake(_tableView.left, _tableView.top-1,
                                     _tableView.width, kShadowHeight);

      UIView* superview = self.superviewForSearchResults;
      [superview addSubview:_tableView];

      if (_tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        [superview addSubview:_shadowView];
      }
    }

    [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:NO];

  } else {
    [_tableView removeFromSuperview];
    [_shadowView removeFromSuperview];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)superviewForSearchResults {
  UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
  if (scrollView) {
    return scrollView;

  } else {
    for (UIView* view = self.superview; view; view = view.superview) {
      if (view.height > kDesiredTableHeight) {
        return view;
      }
    }

    return self.superview;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
  UIView* superview = self.superviewForSearchResults;

  CGFloat y = 0;
  UIView* view = self;
  while (view != superview) {
    y += view.top;
    view = view.superview;
  }

  CGFloat height = self.height;
  CGFloat keyboardHeight = withKeyboard ? TTKeyboardHeight() : 0;
  CGFloat tableHeight = self.window.height - (self.ttScreenY + height + keyboardHeight);

  return CGRectMake(0, y + self.height-1, superview.frame.size.width, tableHeight+1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdate:(BOOL)emptyText {
  [self delayedUpdate];
  return YES;
}


@end
