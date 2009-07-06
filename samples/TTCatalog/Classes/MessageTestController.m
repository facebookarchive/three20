
#import "MessageTestController.h"
#import "SearchTestController.h"
#import "MockDataSource.h"

@implementation MessageTestController

- (id)init {
  if (self = [super init]) {
    _sendTimer = nil;
    _dataSource = nil;
  }
  return self;
}

- (void)dealloc {
  [_sendTimer invalidate];
  [_dataSource release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)compose {
  id recipient = [TTTableTextItem itemWithText:@"Alan Jones" URL:TT_NULL_URL];
  TTMessageController* controller = [[[TTMessageController alloc] 
    initWithRecipients:[NSArray arrayWithObject:recipient]] autorelease];
  controller.dataSource = _dataSource;
  controller.delegate = self;

  UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
  [navController pushViewController:controller animated:NO];
  [controller presentModalViewController:navController animated:YES];
  [self presentModalViewController:navController animated:YES];
}

- (void)cancelAddressBook {
  [[TTNavigationCenter defaultCenter].frontViewController dismissModalViewControllerAnimated:YES];
}

- (void)sendDelayed:(NSTimer*)timer {
  _sendTimer = nil;
  
  NSArray* fields = timer.userInfo;
  UIView* lastView = [self.view.subviews lastObject];
  CGFloat y = lastView.bottom + 20;
  
  TTMessageRecipientField* toField = [fields objectAtIndex:0];
  for (id recipient in toField.recipients) {
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = self.view.backgroundColor;
    label.text = [NSString stringWithFormat:@"Sent to: %@", recipient];
    [label sizeToFit];
    label.frame = CGRectMake(30, y, label.width, label.height);
    y += label.height;
    [self.view addSubview:label];
  }
  
  [self.modalViewController dismissModalViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  self.view = [[[UIView alloc] initWithFrame:appFrame] autorelease];;
  self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
  
  _dataSource = [[MockDataSource mockDataSource:YES] retain];
  
  UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setTitle:@"Compose Message" forState:UIControlStateNormal];
  [button addTarget:self action:@selector(compose)
    forControlEvents:UIControlEventTouchUpInside];
  button.frame = CGRectMake(20, 20, 280, 50);
  [self.view addSubview:button];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTMessageControllerDelegate

- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields {
  _sendTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
    selector:@selector(sendDelayed:) userInfo:fields repeats:NO];
}

- (void)composeControllerDidCancel:(TTMessageController*)controller {
  [_sendTimer invalidate];
  _sendTimer = nil;

  [controller dismissModalViewControllerAnimated:YES];
}

- (void)composeControllerShowRecipientPicker:(TTMessageController*)controller {
  SearchTestController* searchController = [[[SearchTestController alloc] init] autorelease];
  searchController.delegate = self;
  searchController.title = @"Address Book";
  searchController.navigationItem.prompt = @"Select a recipient";
  searchController.navigationItem.rightBarButtonItem = 
    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:self action:@selector(cancelAddressBook)] autorelease];
    
  UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
  [navController pushViewController:searchController animated:NO];
  [controller presentModalViewController:navController animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// SearchTestControllerDelegate

- (void)searchTestController:(SearchTestController*)controller didSelectObject:(id)object {
  TTMessageController* composeController = (TTMessageController*)self.modalViewController;
  [composeController addRecipient:object forFieldAtIndex:0];
  [controller dismissModalViewControllerAnimated:YES];
}

@end
