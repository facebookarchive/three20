#import "Three20/TTGlobal.h"

@interface TTYouTubeView : UIWebView {
  NSString* _url;
}

@property(nonatomic,copy) NSString* url;

- (id)initWithURL:(NSString*)url;

@end
