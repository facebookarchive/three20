#import "Three20/T3Global.h"

@interface T3YouTubeView : UIWebView {
  NSString* url;
}

@property(nonatomic,copy) NSString* url;

- (id)initWithURL:(NSString*)url;

@end
