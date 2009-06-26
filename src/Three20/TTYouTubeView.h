#import "Three20/TTGlobal.h"

@interface TTYouTubeView : UIWebView {
  NSString* _URL;
}

@property(nonatomic,copy) NSString* URL;

- (id)initWithURL:(NSString*)URL;

@end
