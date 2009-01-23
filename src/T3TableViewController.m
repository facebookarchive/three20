#import "Three20/T3TableViewController.h"

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
// T3ViewController

- (void)updateView {
  [_tableView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
