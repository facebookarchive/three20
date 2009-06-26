#import "TableItemTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kLoremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do\
 eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud\
  exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
//Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\
 pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\
 mollit anim id est laborum.

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableItemTestController

- (void)dealloc {
  [super dealloc];
}

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
  // This demonstrates how to create a table with standard table "fields".  Many of these
  // fields with URLs that will be visited when the row is selected
  return [TTSectionedDataSource dataSourceWithObjects:
    @"Buttons",
    [[[TTTableItem alloc] initWithText:@"TTTableItem"
      URL:@"tt://tableFieldTest"] autorelease],
    [[[TTTableItem alloc] initWithText:@"TTTableItem (external link)"
      URL:@"http://foo.com"] autorelease],
    [[[TTLinkTableItem alloc] initWithText:@"TTLinkTableItem"
      URL:@"tt://tableFieldTest"] autorelease],
    [[[TTIconTableItem alloc] initWithText:@"TTIconTableItem" URL:@"tt://tableFieldTest"
      image:@"bundle://tableIcon.png" ] autorelease],
    [[[TTImageTableItem alloc] initWithText:@"TTImageTableItem" URL:@"tt://tableFieldTest"
      image:@"bundle://person.jpg"] autorelease],
    [[[TTButtonTableItem alloc] initWithText:@"TTButtonTableItem"] autorelease],
    [[[TTTitledTableItem alloc] initWithTitle:@"title"
      text:@"TTTitledTableItem" URL:@"tt://tableFieldTest"] autorelease],
    [[[TTMoreButtonTableItem alloc] initWithText:@"TTMoreButtonTableItem"
      subtitle:@"Showing 1 of 100"] autorelease],

    @"Static Text",
    [[[TTTableItem alloc] initWithText:@"TTTableItem"] autorelease],
    [[[TTTitledTableItem alloc] initWithTitle:@"title"
      text:@"TTTitledTableItem which wraps to several lines"] autorelease],
    [[[TTSubtextTableItem alloc] initWithText:@"TTSubtextTableItem"
      subtext:kLoremIpsum] autorelease],
    [[[TTTextTableItem alloc] initWithText:kLoremIpsum] autorelease],
    [[[TTGrayTextTableItem alloc] initWithText:kLoremIpsum] autorelease],
    [[[TTSummaryTableItem alloc] initWithText:@"TTSummaryTableItem"] autorelease],

    @"",
    [[[TTActivityTableItem alloc] initWithText:@"TTActivityTableItem"] autorelease],

    nil];
}

@end
