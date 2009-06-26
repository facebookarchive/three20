#import "TableControlsTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableControlsTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.autoresizesForKeyboard = YES;
  self.variableHeightRows = YES;
  
  self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [TTSectionedDataSource dataSourceWithObjects:
    @"Controls",
    [[[TTSwitchTableField alloc] initWithText:@"TTSwitchTableField"] autorelease],
    [[[TTTextFieldTableField alloc] initWithTitle:@"Title" text:@"TTTextFieldTableField"]
      autorelease],
    [[[TTTextViewTableField alloc] initWithText:@"TTTextViewTableField"] autorelease],

    nil];
}

@end
