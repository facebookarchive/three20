#import "SearchTestController.h"

@class MockDataSource;

@interface ComposerTestController : UIViewController
  <TTComposeControllerDelegate, SearchTestControllerDelegate> {
  MockDataSource* _dataSource;
  NSTimer* _sendTimer;
}

@end

