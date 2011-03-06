#import "SplitCatalogController.h"

#import "CatalogController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface SplitCatalogController()

- (void)setupNavigators;

@end



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SplitCatalogController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    [self setupNavigators];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)willOpenUrlPath:(NSURL*)url {
  NSString* urlPath = [url absoluteString];
  if (nil == self.primaryNavigator.rootViewController) {
    // First run-through, let the navigator set up the root navigator controller as necessary.
    // This will eventually pipe through setRootViewController: found below.
    [self.primaryNavigator openURLAction:[TTURLAction actionWithURLPath:urlPath]];

  } else {
    // Subsequent runthroughs, we just forcefully reset the navigation stack.
    UIViewController* viewController = [self.primaryNavigator viewControllerForURL:urlPath];

    UINavigationController* navController =
    (UINavigationController*)self.primaryNavigator.rootViewController;
    [navController setViewControllers: [NSArray arrayWithObject:viewController]
                             animated: NO];
  }

  // Don't create a view controller here; we're forwarding the URL routing.
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupSecondaryNavigator {
  TTURLMap* map = self.secondaryNavigator.URLMap;

  // Forward all unhandled URL actions to the right navigator.
  [map                    from: @"*"
                      toObject: self
                      selector: @selector(willOpenUrlPath:)];

  [map                    from: @"tt://catalog"
              toViewController: [CatalogController class]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupPrimaryNavigator {
  TTURLMap* map = self.primaryNavigator.URLMap;


  [map                    from: @"*"
              toViewController: [TTWebController class]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupNavigators {
  [self setupPrimaryNavigator];
  [self setupSecondaryNavigator];

  [self.secondaryNavigator openURLs:@"tt://catalog", nil];
  [self.primaryNavigator openURLs:@"http://three20.info/", nil];
}


@end

