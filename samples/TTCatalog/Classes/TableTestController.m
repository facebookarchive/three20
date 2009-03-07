
#import "TableTestController.h"
#import "MockDataSource.h"

@implementation TableTestController

- (id)init {
  if (self = [super init]) {
    self.contentState = TTContentError;
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
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  self.view = [[[UIView alloc] initWithFrame:appFrame] autorelease];
     
  self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.sectionIndexMinimumDisplayRowCount = 2;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [MockDataSource mockDataSource:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
