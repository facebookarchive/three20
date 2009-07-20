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

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    self.tableViewStyle = UITableViewStyleGrouped;
    self.autoresizesForKeyboard = YES;
    self.variableHeightRows = YES;

    // This demonstrates how to create a table with standard table "fields".  Many of these
    // fields with URLs that will be visited when the row is selected
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
      @"Links and Buttons",
      [TTTableTextItem itemWithText:@"TTTableTextItem" URL:@"tt://tableItemTest"],
      [TTTableLink itemWithText:@"TTTableLink" URL:@"tt://tableItemTest"],
      [TTTableButton itemWithText:@"TTTableButton"],
      [TTTableCaptionedItem itemWithText:@"TTTableCaptionedItem" caption:@"caption"
                             URL:@"tt://tableItemTest"],
      [TTTableMessageItem itemWithTitle:@"Bob Jones" caption:@"TTTableMessageItem"
                          text:kLoremIpsum timestamp:[NSDate date] URL:@"tt://tableItemTest"],
      [TTTableMoreButton itemWithText:@"TTTableMoreButton"],

      @"Images",
      [TTTableImageItem itemWithText:@"TTTableImageItem" URL:@"tt://tableItemTest"
                        imageURL:@"bundle://tableIcon.png"],
      [TTTableRightImageItem itemWithText:@"TTTableRightImageItem" URL:@"tt://tableItemTest"
                             imageURL:@"bundle://person.jpg"],
      [TTTableMessageItem itemWithTitle:@"Bob Jones" caption:@"TTTableMessageItem"
                          text:kLoremIpsum timestamp:[NSDate date]
                          imageURL:@"bundle://person.jpg" URL:@"tt://tableItemTest"],

      @"Static Text",
      [TTTableTextItem itemWithText:@"TTTableItem"],
      [TTTableCaptionedItem itemWithText:@"TTTableCaptionedItem which wraps to several lines"
                            caption:@"Text"],
      [TTTableBelowCaptionedItem itemWithText:@"TTTableBelowCaptionedItem"
                                 caption:kLoremIpsum],
      [TTTableLongTextItem itemWithText:[@"TTTableLongTextItem "
                                         stringByAppendingString:kLoremIpsum]],
      [TTTableGrayTextItem itemWithText:[@"TTTableGrayTextItem "
                                         stringByAppendingString:kLoremIpsum]],
      [TTTableSummaryItem itemWithText:@"TTTableSummaryItem"],

      @"",
      [TTTableActivityItem itemWithText:@"TTTableActivityItem"],

      nil];
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end
