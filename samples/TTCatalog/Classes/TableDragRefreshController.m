
#import "TableDragRefreshController.h"
#import "MockDataSource.h"

@implementation TableDragRefreshController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
}

- (void) createModel {
  MockDataSource *ds = [[MockDataSource alloc] init];
  ds.addressBook.fakeLoadingDuration = 1.0;
  self.dataSource = ds;
  [ds release];
}

- (id<TTTableViewDelegate>) createDelegate {
  
  TTTableViewDragRefreshDelegate *delegate = [[TTTableViewDragRefreshDelegate alloc] initWithController:self];

  return [delegate autorelease];
}

@end

