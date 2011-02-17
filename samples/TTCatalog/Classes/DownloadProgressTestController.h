#import <Three20/Three20.h>

@class DownloadTestModel;
@interface DownloadProgressTestController : TTViewController <TTModelDelegate> {
  NSUInteger        _defaultMaxContentLength;
  TTActivityLabel   *_activityLabel;
  DownloadTestModel *_loadingModel;
  NSTimer           *_progressTimer;
}
@end
