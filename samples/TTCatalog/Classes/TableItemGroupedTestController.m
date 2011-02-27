#import "TableItemGroupedTestController.h"
#import <Three20UI/UIViewAdditions.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TableItemGroupedTestStyleSheet : TTDefaultStyleSheet
@end

@implementation TableItemGroupedTestStyleSheet
- (TTStyle*)tableHeaderGrouped {

  UIColor* textColor = TTSTYLEVAR(tableTitleTextColor);
  UIColor* labelColor = [UIColor whiteColor];
  int fontSize = 18;

  return
  	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
   	[TTInsetStyle styleWithInset:UIEdgeInsetsMake(6, 10, 6, 100) next:
    [TTSolidFillStyle styleWithColor:labelColor next:
    [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(5, 25, 5, 0) next:
    [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:fontSize]
                         color:textColor
                 textAlignment:UITextAlignmentLeft
                          next:nil]]]]];
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableItemGroupedTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Table Items Grouped";
		self.tableViewStyle = UITableViewStyleGrouped;

    // Uncomment this to see how the table cells look against a custom background color
    //self.tableView.backgroundColor = [UIColor yellowColor];

    [TTStyleSheet setGlobalStyleSheet:[[[TableItemGroupedTestStyleSheet alloc] init] autorelease]];
  }
  return self;
}

- (void)dealloc {
  [TTStyleSheet setGlobalStyleSheet:nil];
  [super dealloc];
}

@end
