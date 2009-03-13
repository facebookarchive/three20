
#import "TableTestController.h"
#import "MockDataSource.h"

@implementation TableTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)cycle {
  if (!self.viewState) {
    [self invalidateViewState:TTViewLoading];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Error" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  } else if (self.viewState & TTViewLoading) {
    [self invalidateViewState:TTViewDataLoadedError];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Empty" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  } else if (self.viewState & TTViewDataLoadedError) {
    [self invalidateViewState:TTViewEmpty];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Loading" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController
//
- (void)loadView {
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
    initWithTitle:@"Loading" style:UIBarButtonItemStyleBordered target:self
    action:@selector(cycle)] autorelease];
  
  self.view = [[[UIView alloc] initWithFrame:TTApplicationFrame()] autorelease];
     
  self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.sectionIndexMinimumDisplayRowCount = 2;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (UIImage*)imageForNoData {
  return [UIImage imageNamed:@"Three20.bundle/images/empty.png"];
}

- (NSString*)titleForNoData {
  return NSLocalizedString(@"No Friends", @"");
}

- (NSString*)subtitleForNoData {
  return NSLocalizedString(@"Try getting some friends.", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return [UIImage imageNamed:@"Three20.bundle/images/error.png"];
}

- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"There was an error loading your friends.", @"");
}


@end
