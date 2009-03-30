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
    @"This is a whole bunch of text made from characters and followed by this url http://bit.ly/1234",
    @"Here we have a url http://www.h0tlinkz.com followed by another http://www.internets.com",
    @"http://www.cnn.com is a url and the words you are now reading are the text that follows",
//    @"Let's test out some line breaks.\n\nOh yeah.",
//    @"This is a message with a long url in it http://www.foo.com/abra/cadabra/abrabra/dabarababa",
    nil];

  TTListDataSource* dataSource = [[[TTListDataSource alloc] init] autorelease];
  for (int i = 0; i < 50; ++i) {
    NSString* string = [strings objectAtIndex:i % strings.count];
    NSString* title = [NSString stringWithFormat:@"Row %d: ", i+1];
    TTHTMLNode* body = [TTHTMLNode htmlFromURLString:string];
    TTHTMLNode* html = [[[TTHTMLBoldNode alloc] initWithText:title next:body] autorelease];
    TTHTMLTableField* field = [[[TTHTMLTableField alloc] initWithHTML:html url:@"tt://htmlTest"]
                                 autorelease];
    [dataSource.items addObject:field];
  }
  return dataSource;
}

@end
