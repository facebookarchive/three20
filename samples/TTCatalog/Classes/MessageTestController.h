#import "SearchTestController.h"

@class MockDataSource;

@interface MessageTestController : UIViewController
  <TTMessageControllerDelegate, SearchTestControllerDelegate> {
  NSTimer* _sendTimer;
}

@end

