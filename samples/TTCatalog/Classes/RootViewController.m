#import "RootViewController.h"
#import "Three20/developer.h"

@implementation RootViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)selectTestRow {
#ifdef JOE
  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:TEST_ROW inSection:TEST_SECTION];
  [self.tableView touchRowAtIndexPath:indexPath animated:NO];
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    self.tableViewStyle = UITableViewStyleGrouped;

    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(selectTestRow)
             userInfo:nil repeats:NO];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [TTSectionedDataSource dataSourceWithObjects:
    @"Photos",
    [TTTableTextItem itemWithText:@"Photo Browser" URL:@"tt://photoTest1"],
    [TTTableTextItem itemWithText:@"Photo Thumbnails" URL:@"tt://photoTest2"],

    @"Text Fields",
    [TTTableTextItem itemWithText:@"Message Composer" URL:@"tt://composerTest"],
    [TTTableTextItem itemWithText:@"Search Bar" URL:@"tt://searchTest"],

    @"Styles",
    [TTTableTextItem itemWithText:@"Styled Views" URL:@"tt://styleTest"],
    [TTTableTextItem itemWithText:@"Styled Labels" URL:@"tt://styledTextTest"],

    @"Controls",
    [TTTableTextItem itemWithText:@"Buttons" URL:@"tt://buttonTest"],
    [TTTableTextItem itemWithText:@"Tabs" URL:@"tt://tabBarTest"],

    @"Tables",
    [TTTableTextItem itemWithText:@"Table States" URL:@"tt://tableTest"],
    [TTTableTextItem itemWithText:@"Table Items" URL:@"tt://tableItemTest"],
    [TTTableTextItem itemWithText:@"Table Controls" URL:@"tt://tableControlsTest"],
    [TTTableTextItem itemWithText:@"Styled Labels in Table" URL:@"tt://styledTextTableTest"],
    [TTTableTextItem itemWithText:@"Web Images in Table" URL:@"tt://imageTest2"],

    @"General",
    [TTTableTextItem itemWithText:@"Web Image" URL:@"tt://imageTest1"],
    [TTTableTextItem itemWithText:@"YouTube Player" URL:@"tt://youTubeTest"],
    [TTTableTextItem itemWithText:@"Web Browser" URL:@"tt://webTest"],
    [TTTableTextItem itemWithText:@"Activity Labels" URL:@"tt://activityTest"],
    [TTTableTextItem itemWithText:@"Scroll View" URL:@"tt://scrollViewTest"],
    nil];
}

@end
