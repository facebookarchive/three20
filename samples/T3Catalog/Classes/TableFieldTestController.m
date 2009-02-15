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

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStyleGrouped];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
  self.dataSource = [T3SectionedDataSource dataSourceWithObjects:
    @"Buttons",
    [[[T3TableField alloc] initWithText:@"T3TableField"
      href:@"t3://tableFieldTest"] autorelease],
    [[[T3TableField alloc] initWithText:@"T3TableField (external)"
      href:@"http://foo.com"] autorelease],
    [[[T3LinkTableField alloc] initWithText:@"T3LinkTableField"
      href:@"t3://tableFieldTest"] autorelease],
    [[[T3IconTableField alloc] initWithText:@"T3IconTableField" href:@"t3://tableFieldTest"
      image:@"bundle://tableIcon.png" ] autorelease],
    [[[T3ImageTableField alloc] initWithText:@"T3ImageTableField" href:@"t3://tableFieldTest"
      image:@"bundle://person.jpg"] autorelease],
    [[[T3ButtonTableField alloc] initWithText:@"T3ButtonTableField"] autorelease],
    [[[T3TitledTableField alloc] initWithTitle:@"title"
      text:@"T3TitledTableField" href:@"t3://tableFieldTest"] autorelease],
    [[[T3MoreButtonTableField alloc] initWithText:@"T3MoreButtonTableField"
      subtitle:@"Showing 1 of 100"] autorelease],

    @"Static Text",
    [[[T3TableField alloc] initWithText:@"T3TableField"] autorelease],
    [[[T3TitledTableField alloc] initWithTitle:@"title"
      text:@"T3TitledTableField"] autorelease],
    [[[T3SubtextTableField alloc] initWithText:@"T3SubtextTableField"
      subtext:kLoremIpsum] autorelease],
    [[[T3TextTableField alloc] initWithText:kLoremIpsum] autorelease],
    [[[T3GrayTextTableField alloc] initWithText:kLoremIpsum] autorelease],
    [[[T3ActivityTableField alloc] initWithText:@"T3ActivityTableField"] autorelease],
    [[[T3SummaryTableField alloc] initWithText:@"T3SummaryTableField"] autorelease],

    @"Controls",
    [[[T3SwitchTableField alloc] initWithText:@"T3SwitchTableField"] autorelease],
    [[[T3TextFieldTableField alloc] initWithTitle:@"Title" text:@"T3TextFieldTableField"]
      autorelease],
    [[[T3TextViewTableField alloc] initWithText:@"T3TextViewTableField"] autorelease],

    nil];
}

@end
