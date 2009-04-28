#import "StyledTextTableTestController.h"

@implementation StyledTextTableTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.autoresizesForKeyboard = YES;
  self.variableHeightRows = YES;
  
  self.tableView = [[[TTTableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStylePlain] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  NSArray* strings = [NSArray arrayWithObjects:
    [TTStyledText textFromXHTML:@"This is a whole bunch of text made from \
characters and followed by this url http://bit.ly/1234"],
    [TTStyledText textFromXHTML:@"Here we have a url http://www.h0tlinkz.com \
followed by another http://www.internets.com"],
    [TTStyledText textFromXHTML:@"http://www.cnn.com is a url and the words you \
are now reading are the text that follows"],
    [TTStyledText textFromXHTML:@"Here is text that has absolutely no styles. \
Move along now. Nothing to see here. Goodbye now."],
//    @"Let's test out some line breaks.\n\nOh yeah.",
//    @"This is a message with a long url in it http://www.foo.com/abra/cadabra/abrabra/dabarababa",
    nil];
  NSString* url = @"tt://styledTextTableTest";

  TTListDataSource* dataSource = [[[TTListDataSource alloc] init] autorelease];
  for (int i = 0; i < 50; ++i) {
    TTStyledText* text = [strings objectAtIndex:i % strings.count];
    
    [dataSource.items addObject:
      [[[TTStyledTextTableField alloc] initWithStyledText:text url:url] autorelease]];
  }
  return dataSource;
}

@end
