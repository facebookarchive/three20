#import "Three20/T3ThumbsViewController.h"
#import "Three20/T3PhotoViewController.h"
#import "Three20/T3ThumbsTableViewCell.h"
#import "Three20/T3PhotoSource.h"
#import "Three20/T3UnclippedView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSInteger kColumnCount = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ThumbsViewController

@synthesize photoSource;

- (id)init {
  if (self = [super init]) {
    photoSource = nil;
    previousBarStyle = 0;
  }
  
  return self;
}

- (void)dealloc {
  [photoSource release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)pauseLoadingThumbnails:(BOOL)paused {
  if (photoSource.numberOfPhotos) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      T3ThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[T3ThumbsTableViewCell class]]) {
        [cell pauseLoading:paused];
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, TOOLBAR_HEIGHT, appFrame.size.width, appFrame.size.height - TOOLBAR_HEIGHT);

  UIView* contentView = [[[T3UnclippedView alloc] initWithFrame:appFrame] autorelease];
  contentView.backgroundColor = [UIColor whiteColor];
//	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  contentView.autoresizesSubviews = YES;
  self.view = contentView;
    
  UITableView* tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
  tableView.rowHeight = 79;
//  tableView.autoresizesSubviews = YES;
//	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  tableView.backgroundColor = [UIColor whiteColor];
  tableView.separatorColor = [UIColor whiteColor];
  tableView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
  tableView.clipsToBounds = NO;
  tableView.delegate = self;
  tableView.dataSource = self;
  [self.view addSubview:tableView];
  self.tableView = tableView;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  UINavigationBar* bar = self.navigationController.navigationBar;
  goingBack = !!self.nextViewController;
  if (bar.barStyle != UIBarStyleBlackTranslucent) {
    if (!self.nextViewController) {
      previousBarStyle = bar.barStyle;
    }

    bar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent
      animated:YES];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self pauseLoadingThumbnails:NO];

  if (0) {
    self.tableView.frame = CGRectOffset(self.tableView.frame, 0, TOOLBAR_HEIGHT);
  } else {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }

//  if (!self.nextViewController && !goingBack) {
//    self.tableView.frame = CGRectOffset(self.tableView.frame, 0, TOOLBAR_HEIGHT);
//  }
}


- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  if (1) {
    self.tableView.frame = CGRectOffset(self.tableView.frame, 0, TOOLBAR_HEIGHT);
  } else {
    self.view.superview.frame = CGRectOffset(self.view.superview.frame, 0, TOOLBAR_HEIGHT);
  }

  // If we're going backwards...
  if (!self.nextViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    if (previousBarStyle != UIBarStyleBlackTranslucent) {
      bar.barStyle = previousBarStyle;
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
  }
}  

- (void)viewDidDisappear:(BOOL)animated {
  [self pauseLoadingThumbnails:YES];
  [super viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ViewController

- (id<T3Object>)viewObject {
  return photoSource;
}

- (void)showObject:(id<T3Object>)object inView:(NSString*)name withState:(NSDictionary*)state {
  [super showObject:object inView:name withState:state];

  self.photoSource = (id<T3PhotoSource>)object;
}

- (void)updateContent {
  self.navigationItem.title = photoSource.title;

  if (photoSource.loading) {
    [self setContentStateActivity:@"Loading..."];
  } else if (photoSource.isInvalid) {
    [photoSource loadPhotosFromIndex:0 toIndex:NSUIntegerMax delegate:self];
  } else if (!photoSource.numberOfPhotos) {
    self.contentState = T3ViewContentEmpty;
  } else {
    self.contentState = T3ViewContentReady;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (photoSource.numberOfPhotos / kColumnCount) + 
    (photoSource.numberOfPhotos % kColumnCount ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"Thumbs";
	
	T3ThumbsTableViewCell *cell =
    (T3ThumbsTableViewCell*)[_tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[T3ThumbsTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
	}
	
  cell.photo = [photoSource photoAtIndex:indexPath.row * kColumnCount];
 
	return cell;
}

- (void)tableView:(UITableView*)aTableView didSelectPhoto:(id<T3Photo>)photo {
  T3PhotoViewController* controller = [[[T3PhotoViewController alloc] init] autorelease];
  controller.visiblePhoto = photo;
  [self.navigationController pushViewController:controller animated:YES];  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoSourceDelegate

- (void)photoSourceLoading:(id<T3PhotoSource>)aPhotoSource fromIndex:(NSUInteger)fromIndex
   toIndex:(NSUInteger)toIndex {
  [self setContentStateActivity:@"Loading..."];
}

- (void)photoSourceLoaded:(id<T3PhotoSource>)aPhotoSource {
  if (photoSource.numberOfPhotos) {
    self.contentState = T3ViewContentReady;
  } else {
    self.contentState = T3ViewContentEmpty;
  }
}

- (void)photoSource:(id<T3PhotoSource>)aPhotoSource loadFailedWithError:(NSError*)error {
  [self setContentStateError:error];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhotoSource:(id<T3PhotoSource>)aPhotoSource {
  if (aPhotoSource != photoSource) {
    [photoSource release];
    photoSource = [aPhotoSource retain];

    [self invalidate:T3ViewInvalidContent];
  }
}

@end
