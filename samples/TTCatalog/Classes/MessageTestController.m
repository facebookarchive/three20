
#import "MessageTestController.h"
#import "SearchTestController.h"
#import "MockDataSource.h"

@implementation MessageTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIViewController*)composeTo:(NSString*)recipient {
  TTTableTextItem* item = [TTTableTextItem itemWithText:recipient URL:nil];

  TTMessageController* controller =
    [[[TTMessageController alloc] initWithRecipients:[NSArray arrayWithObject:item]] autorelease];
  controller.dataSource = [[[MockSearchDataSource alloc] init] autorelease];
  controller.delegate = self;

  return controller;
}

- (void)showPost:(UIButton*)button {
  TTPostController* controller = [[[TTPostController alloc] init] autorelease];
  controller.originView = button;
  [controller showInView:self.view animated:YES];
}

- (void)cancelAddressBook {
  [[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}

- (void)sendDelayed:(NSTimer*)timer {
  _sendTimer = nil;
  
  NSArray* fields = timer.userInfo;
  UIView* lastView = [self.view.subviews lastObject];
  CGFloat y = lastView.bottom + 20;
  
  TTMessageRecipientField* toField = [fields objectAtIndex:0];
  for (id recipient in toField.recipients) {
    UILabel* label = [[[UILabel alloc] init] autorelease];
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
// NSObject

- (id)init {
  if (self = [super init]) {
    _sendTimer = nil;
    
    [[TTNavigator navigator].URLMap from:@"tt://compose?to=(composeTo:)"
                                    toModalViewController:self selector:@selector(composeTo:)];
  }
  return self;
}

- (void)dealloc {
  [[TTNavigator navigator].URLMap removeURL:@"tt://compose?to=(composeTo:)"];
  [_sendTimer invalidate];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  self.view = [[[UIView alloc] initWithFrame:appFrame] autorelease];;
  self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
  
  UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setTitle:@"Show TTMessageController" forState:UIControlStateNormal];
  [button addTarget:@"tt://compose?to=Alan%20Jones" action:@selector(openURL)
          forControlEvents:UIControlEventTouchUpInside];
  button.frame = CGRectMake(20, 20, 280, 50);
  [self.view addSubview:button];

  UIButton* button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button2 setTitle:@"Show TTPostController" forState:UIControlStateNormal];
  [button2 addTarget:self action:@selector(showPost:)
          forControlEvents:UIControlEventTouchUpInside];
  button2.frame = CGRectMake(20, button.bottom + 20, 280, 50);
  [self.view addSubview:button2];
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
