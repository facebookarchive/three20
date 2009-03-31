#import "TableFieldTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kLoremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do\
 eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud\
  exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
//Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\
 pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\
 mollit anim id est laborum.

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableFieldTestController

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
    [[[TTTableField alloc] initWithText:@"TTTableField"
      url:@"tt://tableFieldTest"] autorelease],
    [[[TTTableField alloc] initWithText:@"TTTableField (external link)"
      url:@"http://foo.com"] autorelease],
    [[[TTLinkTableField alloc] initWithText:@"TTLinkTableField"
      url:@"tt://tableFieldTest"] autorelease],
    [[[TTIconTableField alloc] initWithText:@"TTIconTableField" url:@"tt://tableFieldTest"
      image:@"bundle://tableIcon.png" ] autorelease],
    [[[TTImageTableField alloc] initWithText:@"TTImageTableField" url:@"tt://tableFieldTest"
      image:@"bundle://person.jpg"] autorelease],
    [[[TTButtonTableField alloc] initWithText:@"TTButtonTableField"] autorelease],
    [[[TTTitledTableField alloc] initWithTitle:@"title"
      text:@"TTTitledTableField" url:@"tt://tableFieldTest"] autorelease],
    [[[TTMoreButtonTableField alloc] initWithText:@"TTMoreButtonTableField"
      subtitle:@"Showing 1 of 100"] autorelease],

    @"Static Text",
    [[[TTTableField alloc] initWithText:@"TTTableField"] autorelease],
    [[[TTTitledTableField alloc] initWithTitle:@"title"
      text:@"TTTitledTableField which wraps to several lines"] autorelease],
    [[[TTSubtextTableField alloc] initWithText:@"TTSubtextTableField"
      subtext:kLoremIpsum] autorelease],
    [[[TTTextTableField alloc] initWithText:kLoremIpsum] autorelease],
    [[[TTGrayTextTableField alloc] initWithText:kLoremIpsum] autorelease],
    [[[TTSummaryTableField alloc] initWithText:@"TTSummaryTableField"] autorelease],

    @"Activity",
    [[[TTActivityTableField alloc] initWithText:@"TTActivityTableField"] autorelease],

    @"Controls",
    [[[TTSwitchTableField alloc] initWithText:@"TTSwitchTableField"] autorelease],
    [[[TTTextFieldTableField alloc] initWithTitle:@"Title" text:@"TTTextFieldTableField"]
      autorelease],
    [[[TTTextViewTableField alloc] initWithText:@"TTTextViewTableField"] autorelease],

    nil];
}

@end
