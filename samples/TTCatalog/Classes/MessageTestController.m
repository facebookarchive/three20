
#import "MessageTestController.h"
#import "SearchTestController.h"
#import "MockDataSource.h"
#import <Three20UI/UIViewAdditions.h>

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

- (UIViewController*)post:(NSDictionary*)query {
  TTPostController* controller = [[[TTPostController alloc] initWithNavigatorURL:nil
																		   query:
								   [NSDictionary dictionaryWithObjectsAndKeys:@"Default Text", @"text", nil]]
								   autorelease];
  controller.originView = [query objectForKey:@"__target__"];
  return controller;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _sendTimer = nil;

    [[TTNavigator navigator].URLMap from:@"tt://compose?to=(composeTo:)"
                                    toModalViewController:self selector:@selector(composeTo:)];

    [[TTNavigator navigator].URLMap from:@"tt://post"
                                    toViewController:self selector:@selector(post:)];
  }
  return self;
}

- (void)dealloc {
  [[TTNavigator navigator].URLMap removeURL:@"tt://compose?to=(composeTo:)"];
  [[TTNavigator navigator].URLMap removeURL:@"tt://post"];
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
  button.frame = CGRectMake(20, 20, appFrame.size.width - 40, 50);
  [self.view addSubview:button];

  UIButton* button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button2 setTitle:@"Show TTPostController" forState:UIControlStateNormal];
  [button2 addTarget:@"tt://post" action:@selector(openURLFromButton:)
          forControlEvents:UIControlEventTouchUpInside];
  button2.frame = CGRectMake(20, button.bottom + 20, appFrame.size.width - 40, 50);
  [self.view addSubview:button2];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
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
