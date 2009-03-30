#import "HTMLTestController.h"

@implementation HTMLTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.autoresizesForKeyboard = YES;
  self.variableHeightRows = YES;
  
  self.tableView = [[TTHTMLTableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStylePlain];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  NSArray* strings = [NSArray arrayWithObjects:
    @"My grandma owned a fruit tree down by the river -- now they're cutting it down! http://bit.ly/1234",
    @"This is my favorite website: http://www.h0tlinkz.com and this one is good too http://www.internets.com",
    @"http://www.cnn.com is the best source for all the latest updates on britney and jessica simpson",
//    @"Let's test out some line breaks.\n\nOh yeah.",
//    @"This is a message with a long url in it http://www.foo.com/abra/cadabra/abrabra/dabarababa",
    nil];

  TTListDataSource* dataSource = [[[TTListDataSource alloc] init] autorelease];
  for (int i = 0; i < 50; ++i) {
    NSString* string = [strings objectAtIndex:i % strings.count];
    TTHTMLNode* html = [TTHTMLNode htmlFromURLString:string];
    TTHTMLTableField* field = [[[TTHTMLTableField alloc] initWithHTML:html
        url:@"tt://htmlTest"] autorelease];
    [dataSource.items addObject:field];
  }
  return dataSource;
}

@end
