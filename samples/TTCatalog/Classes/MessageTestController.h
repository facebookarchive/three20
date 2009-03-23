#import "SearchTestController.h"

@class MockDataSource;

@interface MessageTestController : UIViewController
  <TTMessageControllerDelegate, SearchTestControllerDelegate> {
  MockDataSource* _dataSource;
  NSTimer* _sendTimer;
}

@end

