#import "Three20/T3TableViewController.h"
#import "Three20/T3ErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableViewController

@synthesize tableView = _tableView;

- (id)init {
  if (self = [super init]) {
    _tableView = nil;
  }  
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}  

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ViewController

- (void)updateView {
  if (self.contentState & T3ContentReady) {
    [_tableView reloadData];
  }
  
  [super updateView];
}

- (void)unloadView {
  [_tableView release];
  [super unloadView];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTableView:(UITableView*)tableView {
  if (_tableView != tableView) {
    [_tableView release];
    _tableView = [tableView retain];
  }
}

@end
