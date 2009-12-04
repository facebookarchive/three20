/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTThumbsViewController.h"
#import "Three20/TTPhotoViewController.h"
#import "Three20/TTURLRequest.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static CGFloat kThumbnailRowHeight = 79;
static CGFloat kThumbSize = 75;
static CGFloat kThumbSpacing = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsDataSource

@synthesize photoSource = _photoSource, delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)hasMoreToLoad {
  return _photoSource.maxPhotoIndex+1 < _photoSource.numberOfPhotos;
}

- (NSInteger)columnCount {
  CGFloat width = TTScreenBounds().size.width;
  return round((width - kThumbSpacing*2) / (kThumbSize+kThumbSpacing));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource
      delegate:(id<TTThumbsTableViewCellDelegate>)delegate {
  if (self = [super init]) {
    _photoSource = [photoSource retain];
    _delegate = delegate;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_photoSource);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger maxIndex = _photoSource.maxPhotoIndex;
  NSInteger columnCount = self.columnCount;
  if (maxIndex >= 0) {
    maxIndex += 1;
    NSInteger count =  ceil((maxIndex / columnCount) + (maxIndex % columnCount ? 1 : 0));
    if (self.hasMoreToLoad) {
      return count + 1;
    } else {
      return count;
    }
  } else {
    return 0;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (id<TTModel>)model {
  return _photoSource;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == [tableView numberOfRowsInSection:0]-1 && self.hasMoreToLoad) {
    NSString* text = TTLocalizedString(@"Load More Photos...", @"");
    NSString* caption = nil;
    if (_photoSource.numberOfPhotos == -1) {
      caption = [NSString stringWithFormat:TTLocalizedString(@"Showing %@ Photos", @""),
                                           TTFormatInteger(_photoSource.maxPhotoIndex+1)];
    } else {
      caption = [NSString stringWithFormat:TTLocalizedString(@"Showing %@ of %@ Photos", @""),
                                           TTFormatInteger(_photoSource.maxPhotoIndex+1),
                                           TTFormatInteger(_photoSource.numberOfPhotos)];
    }
    
    return [TTTableMoreButton itemWithText:text subtitle:caption];
  } else {
    NSInteger columnCount = self.columnCount;
    return [_photoSource photoAtIndex:indexPath.row * columnCount];
  }
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object conformsToProtocol:@protocol(TTPhoto)]) {
    return [TTThumbsTableViewCell class];
  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}

- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
        willAppearAtIndexPath:(NSIndexPath*)indexPath {
  if ([cell isKindOfClass:[TTThumbsTableViewCell class]]) {
    TTThumbsTableViewCell* thumbsCell = (TTThumbsTableViewCell*)cell;
    thumbsCell.delegate = _delegate;
    thumbsCell.columnCount = self.columnCount;
  }
}

- (NSIndexPath*)tableView:(UITableView*)tableView willInsertObject:(id)object
                atIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willRemoveObject:(id)object
                atIndexPath:(NSIndexPath*)indexPath {
  return nil;
}

- (NSString*)titleForEmpty {
  return TTLocalizedString(@"No Photos", @"");
}

- (NSString*)subtitleForEmpty {
  return TTLocalizedString(@"This photo set contains no photos.", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
}

- (NSString*)subtitleForError:(NSError*)error {
  return TTLocalizedString(@"Unable to load this photo set.", @"");
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsViewController

@synthesize delegate = _delegate, photoSource = _photoSource;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)suspendLoadingThumbnails:(BOOL)suspended {
  if (_photoSource.maxPhotoIndex >= 0) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      TTThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[TTThumbsTableViewCell class]]) {
        [cell suspendLoading:suspended];
      }
    }
  }
}

- (void)updateTableLayout {
  self.tableView.contentInset = UIEdgeInsetsMake(TTBarsHeight()+4, 0, 0, 0);
  self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(TTBarsHeight(), 0, 0, 0);
}

- (NSString*)URLForPhoto:(id<TTPhoto>)photo {
  if ([photo respondsToSelector:@selector(URLValueWithName:)]) {
    return [photo URLValueWithName:@"TTPhotoViewController"];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithDelegate:(id<TTThumbsViewControllerDelegate>)delegate {
  if (self = [self init]) {
    self.delegate = delegate;
  }
  return self;
}

- (id)initWithQuery:(NSDictionary*)query {
  id<TTThumbsViewControllerDelegate> delegate = [query objectForKey:@"delegate"];
  if (delegate) {
    return [self initWithDelegate:delegate];
  } else {
    return [self init];
  }
}

- (id)init {
  if (self = [super init]) {
    _delegate = nil;
    _photoSource = nil;
    
    self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.wantsFullScreenLayout = YES;
    self.hidesBottomBarWhenPushed = YES;
  }
  
  return self;
}

- (void)dealloc {
  [_photoSource.delegates removeObject:self];
  TT_RELEASE_SAFELY(_photoSource);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  self.tableView.rowHeight = kThumbnailRowHeight;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  self.tableView.backgroundColor = TTSTYLEVAR(backgroundColor);
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self updateTableLayout];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self suspendLoadingThumbnails:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self suspendLoadingThumbnails:YES];
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self updateTableLayout];
  [self.tableView reloadData];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  NSString* delegate = [[TTNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
  return [super persistView:state];
}

- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  NSString* delegate = [state objectForKey:@"delegate"];
  if (delegate) {
    self.delegate = [[TTNavigator navigator] objectForPath:delegate];
  }
}

- (void)setDelegate:(id<TTThumbsViewControllerDelegate>)delegate {
  _delegate = delegate;

  if (_delegate) {
    self.navigationItem.leftBarButtonItem =
      [[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] init] autorelease]] autorelease];
    self.navigationItem.rightBarButtonItem =
      [[[UIBarButtonItem alloc] initWithTitle:TTLocalizedString(@"Done", @"")
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(removeFromSupercontroller)] autorelease];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)didRefreshModel {
  [super didRefreshModel];
  self.title = _photoSource.title;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (CGRect)rectForOverlayView {
  return TTRectContract(CGRectOffset([super rectForOverlayView], 0, TTBarsHeight()-_tableView.top),
                        0, TTBarsHeight());
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTThumbsTableViewCellDelegate

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
  [_delegate thumbsViewController:self didSelectPhoto:photo];
    
  BOOL shouldNavigate = YES;
  if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
    shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
  }

  if (shouldNavigate) {
    NSString* URL = [self URLForPhoto:photo];
    if (URL) {
      TTOpenURL(URL);
    } else {
      TTPhotoViewController* controller = [self createPhotoViewController];
      controller.centerPhoto = photo;
      [self.navigationController pushViewController:controller animated:YES];  
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    self.title = _photoSource.title;
    self.dataSource = [self createDataSource];
  }
}

- (TTPhotoViewController*)createPhotoViewController {
  return [[[TTPhotoViewController alloc] init] autorelease];
}

- (id<TTTableViewDataSource>)createDataSource {
  return [[[TTThumbsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
}

@end
