
#import "TableTestController.h"
#import "MockDataSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)cycleModelState {
  if (self.modelState == TTModelStateLoading) {
    self.modelState = TTModelStateLoadedError;
  } else if (self.modelState == TTModelStateEmpty) {
    self.modelState = TTModelStateLoading;
  } else if (self.modelState == TTModelStateLoadedError) {
    self.modelState = TTModelStateLoaded;
  } else if (self.modelState == TTModelStateLoaded) {
    self.modelState = TTModelStateEmpty;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
    initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self
    action:@selector(cycleModelState)] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)loadModel {
  self.dataSource = [[[TableTestDataSource alloc] init] autorelease];
}

- (void)modelDidChangeState {
  if (self.modelState == TTModelStateLoading) {
    self.title = @"StateLoading";
  } else if (self.modelState == TTModelStateEmpty) {
    self.title = @"StateEmpty";
  } else if (self.modelState == TTModelStateLoadedError) {
    self.title = @"StateLoadedError";
  } else if (self.modelState == TTModelStateLoaded) {
    self.title = @"StateLoaded";
  }
}

@end
