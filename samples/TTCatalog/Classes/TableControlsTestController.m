#import "TableControlsTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableControlsTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.autoresizesForKeyboard = YES;
  self.variableHeightRows = YES;
  
  self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  UITextField* textField = [[[UITextField alloc] init] autorelease];
  textField.placeholder = @"UITextField";
  textField.font = TTSTYLEVAR(font);
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  
  UITextView* textView = [[[UITextView alloc] init] autorelease];
  textView.text = @"UITextView";
  textView.font = TTSTYLEVAR(font);
  
  UISwitch* switchy = [[[UISwitch alloc] init] autorelease];
  TTTableControlItem* switchItem = [TTTableControlItem itemWithCaption:@"UISwitch" control:switchy];

  UISlider* slider = [[[UISlider alloc] init] autorelease];
  TTTableControlItem* sliderItem = [TTTableControlItem itemWithCaption:@"UISlider" control:slider];
  
  return [TTSectionedDataSource dataSourceWithObjects:
    @"Controls",
    textField,
    textView,
    switchItem,
    sliderItem,
    nil];
}

@end
