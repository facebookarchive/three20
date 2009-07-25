#import "CatalogController.h"
#import "Three20/developer.h"

@implementation CatalogController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    self.title = @"Three20 Catalog";
    self.navigationItem.backBarButtonItem =
      [[[UIBarButtonItem alloc] initWithTitle:@"Catalog" style:UIBarButtonItemStyleBordered
      target:nil action:nil] autorelease];

    self.tableViewStyle = UITableViewStyleGrouped;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {
  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
    @"Photos",
    [TTTableTextItem itemWithText:@"Photo Browser" URL:@"tt://photoTest1"],
    [TTTableTextItem itemWithText:@"Photo Thumbnails" URL:@"tt://photoTest2"],

    @"Styles",
    [TTTableTextItem itemWithText:@"Styled Views" URL:@"tt://styleTest"],
    [TTTableTextItem itemWithText:@"Styled Labels" URL:@"tt://styledTextTest"],

    @"Controls",
    [TTTableTextItem itemWithText:@"Buttons" URL:@"tt://buttonTest"],
    [TTTableTextItem itemWithText:@"Tabs" URL:@"tt://tabBarTest"],
    [TTTableTextItem itemWithText:@"Composers" URL:@"tt://composerTest"],

    @"Tables",
    [TTTableTextItem itemWithText:@"Table Items" URL:@"tt://tableItemTest"],
    [TTTableTextItem itemWithText:@"Table Controls" URL:@"tt://tableControlsTest"],
    [TTTableTextItem itemWithText:@"Styled Labels in Table" URL:@"tt://styledTextTableTest"],
    [TTTableTextItem itemWithText:@"Web Images in Table" URL:@"tt://imageTest2"],
  
    @"Models",
    [TTTableTextItem itemWithText:@"Model Search" URL:@"tt://searchTest"],
    [TTTableTextItem itemWithText:@"Model States" URL:@"tt://tableTest"],
    
    @"General",
    [TTTableTextItem itemWithText:@"Web Image" URL:@"tt://imageTest1"],
    [TTTableTextItem itemWithText:@"YouTube Player" URL:@"tt://youTubeTest"],
    [TTTableTextItem itemWithText:@"Web Browser" URL:@"http://github.com/joehewitt/three20"],
    [TTTableTextItem itemWithText:@"Activity Labels" URL:@"tt://activityTest"],
    [TTTableTextItem itemWithText:@"Scroll View" URL:@"tt://scrollViewTest"],
    nil];
}

@end
