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
    @"Links and Buttons",
    [TTTableTextItem itemWithText:@"TTTableTextItem" URL:@"tt://tableItemTest"],
    [TTTableTextItem itemWithText:@"TTTableTextItem (external link)" URL:@"http://foo.com"],
    [TTTableLink itemWithText:@"TTTableLink" URL:@"tt://tableItemTest"],
    [TTTableButton itemWithText:@"TTTableButton"],
    [TTTableCaptionedItem itemWithText:@"TTTableCaptionedItem" caption:@"caption"
                           URL:@"tt://tableItemTest"],
    [TTTableImageItem itemWithText:@"TTTableImageItem" URL:@"tt://tableItemTest"
                             image:@"bundle://tableIcon.png"],
    [TTTableRightImageItem itemWithText:@"TTTableRightImageItem" URL:@"tt://tableItemTest"
                           image:@"bundle://person.jpg"],
    [TTTableMoreButton itemWithText:@"TTTableMoreButton"],

    @"Static Text",
    [TTTableTextItem itemWithText:@"TTTableItem"],
    [TTTableCaptionedItem itemWithText:@"TTTableCaptionedItem which wraps to several lines"
                          caption:@"Text"],
    [TTTableBelowCaptionedItem itemWithText:@"TTTableBelowCaptionedItem"
                               caption:kLoremIpsum],
    [TTTableLongTextItem itemWithText:kLoremIpsum],
    [TTTableGrayTextItem itemWithText:kLoremIpsum],
    [TTTableSummaryItem itemWithText:@"TTTableSummaryItem"],

    @"",
    [TTTableActivityItem itemWithText:@"TTTableActivityItem"],

    nil];
}

@end
