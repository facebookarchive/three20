
#import "TableTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TableTestDataSource : TTListDataSource
@end

@implementation TableTestDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewDataSource

- (UIImage*)imageForEmpty {
  return TTIMAGE(@"bundle://Three20.bundle/images/empty.png");
}

- (NSString*)titleForEmpty {
  return NSLocalizedString(@"No Friends", @"");
}

- (NSString*)subtitleForEmpty {
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
//  if (self.modelState == TTModelStateNone) {
//    self.modelState = TTModelStateLoading;
//  } else if (self.modelState == TTModelStateLoading) {
//    self.modelState = TTModelStateLoaded;
//  } else if (self.modelState == TTModelStateLoaded) {
//    self.modelState = TTModelStateLoaded|TTModelStateReloading;
//  } else if (self.modelState == TTModelStateLoaded|TTModelStateReloading) {
//    self.modelState = TTModelStateLoadedError;
//  } else if (self.modelState == TTModelStateLoadedError) {
//    self.modelState = TTModelStateNone;
//  }
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

- (void)createModel {
  self.dataSource = [[[TableTestDataSource alloc] init] autorelease];
}

- (void)modelDidChangeState {
//  if (self.modelState == TTModelStateNone) {
//    self.title = @"None";
//  } else if (self.modelState == TTModelStateLoading) {
//    self.title = @"Loading";
//  } else if (self.modelState == TTModelStateLoaded) {
//    self.title = @"Loaded";
//  } else if (self.modelState == TTModelStateLoaded|TTModelStateReloading) {
//    self.title = @"Reloading";
//  } else if (self.modelState == TTModelStateLoadedError) {
//    self.title = @"LoadedError";
//  }
}

@end
