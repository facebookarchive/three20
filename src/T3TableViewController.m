#import "Three20/T3TableViewController.h"
#import "Three20/T3ErrorView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3TableViewController

@synthesize tableView = _tableView, dataSource = _dataSource;

- (id)init {
  if (self = [super init]) {
    _tableView = nil;
    _dataSource = nil;
  }  
  return self;
}

- (void)dealloc {
  [_dataSource release];
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
  if (self.contentState == T3ContentReady) {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
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
