
#import "ComposerTestController.h"
#import "SearchTestController.h"
#import "MockDataSource.h"

@implementation ComposerTestController

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
  id recipient = [[[TTTableField alloc] initWithText:@"Alan Jones" href:TT_NULL_URL] autorelease];
  TTComposeController* controller = [[[TTComposeController alloc] 
    initWithRecipients:[NSArray arrayWithObject:recipient]] autorelease];
  controller.dataSource = _dataSource;
  controller.delegate = self;
  [self presentModalViewController:controller animated:YES];
}

- (void)cancelAddressBook {
  [[TTNavigationCenter defaultCenter].frontViewController dismissModalViewControllerAnimated:YES];
}

- (void)sendDelayed:(NSTimer*)timer {
  _sendTimer = nil;
  
  NSArray* fields = timer.userInfo;
  UIView* lastView = [self.view.subviews lastObject];
  CGFloat y = lastView.bottom + 20;
  
  TTComposerRecipientField* toField = [fields objectAtIndex:0];
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
// TTComposeControllerDelegate

- (void)composeController:(TTComposeController*)controller didSendFields:(NSArray*)fields {
  _sendTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
    selector:@selector(sendDelayed:) userInfo:fields repeats:NO];
}

- (void)composeControllerDidCancel:(TTComposeController*)controller {
  [_sendTimer invalidate];
  _sendTimer = nil;

  [controller dismissModalViewControllerAnimated:YES];
}

- (void)composeControllerShowRecipientPicker:(TTComposeController*)controller {
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
  TTComposeController* composeController = (TTComposeController*)self.modalViewController;
  [composeController addRecipient:object forFieldAtIndex:0];
  [controller dismissModalViewControllerAnimated:YES];
}

@end
