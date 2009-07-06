
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
// UIViewController
//
- (void)loadView {
  [super loadView];

  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
    initWithTitle:@"Loading" style:UIBarButtonItemStyleBordered target:self
    action:@selector(cycle)] autorelease];
  
  self.tableView.sectionIndexMinimumDisplayRowCount = 2;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (UIImage*)imageForNoData {
  return TTIMAGE(@"bundle://Three20.bundle/images/empty.png");
}

- (NSString*)titleForNoData {
  return NSLocalizedString(@"No Friends", @"");
}

- (NSString*)subtitleForNoData {
  return NSLocalizedString(@"Try getting some friends.", @"");
}

- (UIImage*)imageForError:(NSError*)error {
  return TTIMAGE(@"bundle://Three20.bundle/images/error.png");
}

- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"There was an error loading your friends.", @"");
}


@end
