#import "DemoTableViewController.h"

@implementation DemoTableViewController

@synthesize 
headerView = mHeaderView,
footerView = mFooterView
;


/*
 This class can be called with a nib or without a nib. It can show an optional
 table header and / or table footer. 
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

-(void)dealloc {
  TT_RELEASE_SAFELY(mFooterView);
  TT_RELEASE_SAFELY(mHeaderView);
  [super dealloc];
}

/*
 Called both for NIB inits and manual inits
 */
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"DemoTableViewController";
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Root" style:UIBarButtonItemStyleBordered
                                     target:nil action:nil] autorelease];
  }
  return self;
}

/*
 Called for manual inits, but not NIB inits
 */
- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
    self.tableViewStyle = UITableViewStyleGrouped;
  }
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.tableHeaderView = self.headerView;
  self.tableView.tableFooterView = self.footerView;
}
 

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {
  NSString * nibString = nil;
  if (self.nibName){
    nibString = [@"NIB: " stringByAppendingString:self.nibName];
  }
  else {
   nibString = @"Called without a NIB";
  }
  
  
  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
    @"TTTableViewController",
    [TTTableTextItem itemWithText:@"This demonstates a table"],
    [TTTableTextItem itemWithText:nibString],

    nil];
}

@end
