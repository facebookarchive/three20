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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Table Items";
    self.variableHeightRows = YES;

    // Uncomment this to see how the table looks with the grouped style
    //self.tableViewStyle = UITableViewStyleGrouped;

    // Uncomment this to see how the table cells look against a custom background color
    //self.tableView.backgroundColor = [UIColor yellowColor];

    NSString* localImage = @"bundle://tableIcon.png";
    NSString* remoteImage = @"http://profile.ak.fbcdn.net/v223/35/117/q223792_6978.jpg";
    UIImage* defaultPerson = TTIMAGE(@"bundle://defaultPerson.png");

    // This demonstrates how to create a table with standard table "fields".  Many of these
    // fields with URLs that will be visited when the row is selected
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
      @"Links and Buttons",
      [TTTableTextItem itemWithText:@"TTTableTextItem" URL:@"tt://tableItemTest"
                       accessoryURL:@"http://www.google.com"],
      [TTTableLink itemWithText:@"TTTableLink" URL:@"tt://tableItemTest"],
      [TTTableButton itemWithText:@"TTTableButton"],
      [TTTableCaptionItem itemWithText:@"TTTableCaptionItem" caption:@"caption"
                             URL:@"tt://tableItemTest"],
      [TTTableSubtitleItem itemWithText:@"TTTableSubtitleItem" subtitle:kLoremIpsum
                            URL:@"tt://tableItemTest"],
      [TTTableMessageItem itemWithTitle:@"Bob Jones" caption:@"TTTableMessageItem"
                          text:kLoremIpsum timestamp:[NSDate date] URL:@"tt://tableItemTest"],
      [TTTableMoreButton itemWithText:@"TTTableMoreButton"],

      @"Images",
      [TTTableImageItem itemWithText:@"TTTableImageItem" imageURL:localImage
                        URL:@"tt://tableItemTest"],
      [TTTableRightImageItem itemWithText:@"TTTableRightImageItem" imageURL:localImage
                        defaultImage:nil imageStyle:TTSTYLE(rounded)
                        URL:@"tt://tableItemTest"],
      [TTTableSubtitleItem itemWithText:@"TTTableSubtitleItem" subtitle:kLoremIpsum
                            imageURL:remoteImage defaultImage:defaultPerson
                            URL:@"tt://tableItemTest" accessoryURL:nil],
      [TTTableMessageItem itemWithTitle:@"Bob Jones" caption:@"TTTableMessageItem"
                          text:kLoremIpsum timestamp:[NSDate date]
                          imageURL:remoteImage URL:@"tt://tableItemTest"],

      @"Static Text",
      [TTTableTextItem itemWithText:@"TTTableTextItem"],
      [TTTableCaptionItem itemWithText:@"TTTableCaptionItem which wraps to several lines"
                            caption:@"Text"],
      [TTTableSubtextItem itemWithText:@"TTTableSubtextItem"
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
