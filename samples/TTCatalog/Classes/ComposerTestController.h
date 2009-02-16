#import "SearchTestController.h"

@class MockSearchSource;

@interface ComposerTestController : UIViewController
  <TTComposeControllerDelegate, SearchTestControllerDelegate> {
  MockSearchSource* _searchSource;
  NSTimer* _sendTimer;
}

@end

