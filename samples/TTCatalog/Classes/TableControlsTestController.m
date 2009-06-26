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
    [[[TTSwitchTableItem alloc] initWithText:@"TTSwitchTableItem"] autorelease],
    [[[TTTextFieldTableItem alloc] initWithTitle:@"Title" text:@"TTTextFieldTableItem"]
      autorelease],
    [[[TTTextViewTableItem alloc] initWithText:@"TTTextViewTableItem"] autorelease],

    nil];
}

@end
