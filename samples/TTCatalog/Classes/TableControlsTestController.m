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

  UITextField* textField2 = [[[UITextField alloc] init] autorelease];
  textField2.font = TTSTYLEVAR(font);
  textField2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  TTTableControlItem* textFieldItem = [TTTableControlItem itemWithCaption:@"TTTableControlItem" control:textField2];
  
  UITextView* textView = [[[UITextView alloc] init] autorelease];
  textView.text = @"UITextView";
  textView.font = TTSTYLEVAR(font);
  
  TTTextEditor* editor = [[[TTTextEditor alloc] init] autorelease];
  editor.textView.font = TTSTYLEVAR(font);
  editor.backgroundColor = TTSTYLEVAR(backgroundColor);
  editor.autoresizesToText = NO;
  editor.minNumberOfLines = 3;
  editor.placeholder = @"TTTextEditor";
  
  UISwitch* switchy = [[[UISwitch alloc] init] autorelease];
  TTTableControlItem* switchItem = [TTTableControlItem itemWithCaption:@"UISwitch" control:switchy];

  UISlider* slider = [[[UISlider alloc] init] autorelease];
  TTTableControlItem* sliderItem = [TTTableControlItem itemWithCaption:@"UISlider" control:slider];
  
  return [TTListDataSource dataSourceWithObjects:
    textField,
    editor,
    textView,
    textFieldItem,
    switchItem,
    sliderItem,
    nil];
}

@end
