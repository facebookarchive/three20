
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
  if (!self.modelState) {
    self.modelState = TTModelStateLoading;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Error" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  } else if (self.modelState & TTModelStateLoading) {
    self.modelState = TTModelStateLoadedError;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
      initWithTitle:@"Empty" style:UIBarButtonItemStyleBordered target:self
      action:@selector(cycle)] autorelease];
  } else if (self.modelState & TTModelStateLoadedError) {
    self.modelState = TTModelStateEmpty;
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
