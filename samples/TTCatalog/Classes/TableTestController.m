
#import "TableTestController.h"
#import "MockDataSource.h"

@interface TableTestDataSource : TTListDataSource
@end

@implementation TableTestDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

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

@implementation TableTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)cycle {
  if (!self.viewState) {
    self.viewState = TTViewLoading;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Error" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  } else if (self.viewState & TTViewLoading) {
    self.viewState = TTViewLoadedError;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Empty" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  } else if (self.viewState & TTViewLoadedError) {
    self.viewState = TTViewEmpty;
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

  self.tableView.sectionIndexMinimumDisplayRowCount = 2;

  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
    initWithTitle:@"Loading" style:UIBarButtonItemStyleBordered target:self
    action:@selector(cycle)] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [[[TableTestDataSource alloc] init] autorelease];
}

@end
