#import "Three20/T3ViewController.h"
#import "Three20/T3ActivityLabel.h"
#import "Three20/T3ErrorView.h"
#import "Three20/T3URLCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ViewController

@synthesize viewState, contentState, statusView, disabled, appearing, appeared;

- (id)init {
  if (self = [super init]) {  
    viewState = nil;
    statusView = nil;
    validity = T3ViewValid;
    contentState = T3ViewContentNone;
    contentActivityText = nil;
    contentError = nil;
    disabled = NO;
    appearing = NO;
    appeared = NO;
    unloaded = NO;
  }
  return self;
}

- (void)dealloc {
  //NSLog(@"DEALLOC %@", self);
  [viewState release];
  [contentActivityText release];
  [contentError release];
  [statusView release];
  [self unloadView];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)restoreViewFromState {
  if (viewState) {
    [self restoreView:viewState];
    [viewState release];
    viewState = nil;
  }
}

- (void)updateViewInternal {
  T3ViewValidity currentValidity = validity;
  validity = T3ViewValid;
  
  if (currentValidity & T3ViewInvalidContent) {
    [self updateContent];
  }

  if (currentValidity & T3ViewInvalidView) {
    // Ensure the view is loaded
    self.view;

    self.statusView = nil;

    if (contentState == T3ViewContentReady) {
      [self updateView];
      [self restoreViewFromState];
    } else if (contentState == T3ViewContentActivity) {
      [self updateViewWithActivity:contentActivityText];
      [contentActivityText release];
      contentActivityText = nil;
      [self restoreViewFromState];
    } else if (contentState == T3ViewContentEmpty) {
      [self updateViewWithEmptiness];
      [self restoreViewFromState];
    } else if (contentState == T3ViewContentError) {
      [self updateViewWithError:contentError];
      [contentError release];
      contentError = nil;
      [self restoreViewFromState];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
  UIView* contentView = [[[UIView alloc] initWithFrame:appFrame] autorelease];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  contentView.backgroundColor = [UIColor whiteColor];
  self.view = contentView;
}

- (void)viewWillAppear:(BOOL)animated {
  if (unloaded) {
    unloaded = NO;
    [self loadView];
  }

  appearing = YES;
    
  [T3URLCache sharedCache].paused = YES;
  
  if (!disabled && validity != T3ViewValid) {
    [self updateViewInternal];
  }

  appeared = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [T3URLCache sharedCache].paused = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  appearing = NO;
}

- (void)didReceiveMemoryWarning {
  NSLog(@"MEMORY WARNING FOR %@", self);

  if (!appearing) {
    if (appeared) {
      NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
      [self persistView:state];
      viewState = state;
      validity = T3ViewInvalidView;

      NSLog(@"UNLOAD VIEW %@", self);      
      UIView* view = self.view;
      [super didReceiveMemoryWarning];
      if (view.superview) {
        // Sometimes, like when the controller is in a tabbed bar, the view won't
        // be destroyed here like it should by the superclass - so let's do it ourselves!
        while (view.subviews.count) {
          UIView* child = view.subviews.lastObject;
          [child removeFromSuperview];
        }
        unloaded = YES;
      }      

      appeared = NO;
      
      [statusView release];
      statusView = nil;
      [self unloadView];
    }
  }
  
  if (!appeared) {
    validity = T3ViewInvalidContent;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (id<T3Object>)viewObject {
  // Meant to be overridden
  return nil;
}

- (NSString*)viewName {
  // Meant to be overridden
  return nil;
}

- (void)setDisabled:(BOOL)isDisabled {
  disabled = isDisabled;
  if (disabled) {
    [self viewDidDisable];

    if (appeared) {
      [self resetView];
      validity = T3ViewInvalidContent;
    }
  } else {
    [self viewDidEnable];
  }
}

- (void)showObject:(id<T3Object>)object inView:(NSString*)name withState:(NSDictionary*)state {
  [viewState release];
  viewState = [state retain];
}

- (void)persistView:(NSMutableDictionary*)state {
}

- (void)restoreView:(NSDictionary*)state {
} 

- (void)invalidate:(T3ViewValidity)aValidity {
  if (!(validity & aValidity)) {
    validity |= aValidity;
    if (validity & T3ViewInvalidContent) {
      contentState = T3ViewContentNone;
    }
    if (appearing) {
      [self updateViewInternal];
    }
  }
}

- (void)setContentState:(T3ViewContentState)aContentState {
  if (contentState != aContentState) {
    contentState = aContentState;
    [self invalidate:T3ViewInvalidView];
  }
}

- (void)setContentStateActivity:(NSString*)activityText {
  [contentActivityText release];
  contentActivityText = [activityText retain];
  
  [self setContentState:T3ViewContentActivity];
}

- (void)setContentStateError:(NSError*)error {
  [contentError release];
  contentError = [error retain];

  [self setContentState:T3ViewContentError];
}

- (void)reloadContent {
}

- (void)updateContent {
  [self invalidate:T3ViewInvalidView];
}

- (void)updateView {
}

- (void)updateViewWithEmptiness {
  NSString* caption = NSLocalizedString(@"There is nothing to show here.", @"");
  self.statusView = [[[T3ErrorView alloc] initWithTitle:nil caption:caption image:nil]
    autorelease];
}

- (void)updateViewWithActivity:(NSString*)activityText {
  T3ActivityLabel* activityView = [[[T3ActivityLabel alloc] initWithFrame:CGRectZero
      style:T3ActivityLabelStyleGray] autorelease];
  activityView.text = activityText;
  self.statusView = activityView;
}

- (void)updateViewWithError:(NSError*)error {
  NSString* title = NSLocalizedString(@"Error", @"");
  NSString* caption = error.description
    ? error.description
    : NSLocalizedString(@"An error occurred", @"");
  self.statusView = [[[T3ErrorView alloc] initWithTitle:title caption:caption image:nil]
    autorelease];
}

- (void)resetView {
}

- (void)unloadView {
}

- (void)setStatusView:(UIView*)view {
  if (statusView) {
    [statusView removeFromSuperview];
  }

  [statusView release];
  statusView = [view retain];

  if (statusView) {
    [self showStatusView:statusView];
  }
}

- (void)showStatusView:(UIView*)view {
  statusView.frame = self.view.bounds;
  [self.view addSubview:statusView];
}

- (void)viewDidDisable {
}

- (void)viewDidEnable {
}

@end
