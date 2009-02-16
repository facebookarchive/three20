#import "Three20/TTYouTubeView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kDefaultWidth = 140;
static CGFloat kDefaultHeight = 105;

static NSString* kEmbedHTML = @"<html><body style=\"margin:0\">\
<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
       width=\"%0.0f\" height=\"%0.0f\"></embed>\
</body></html>";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTYouTubeView

@synthesize url = _url;

- (id)initWithURL:(NSString*)url {
  if (self = [self initWithFrame:CGRectMake(0, 0, kDefaultWidth, kDefaultHeight)]) {
    self.url = url;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
    @"yt.width = %0.0f; yt.height = %0.0f", self.width, self.height]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setUrl:(NSString*)url {
  [_url release];
  _url = [url copy];

  NSString* html = [NSString stringWithFormat:kEmbedHTML, _url, self.width, self.height];
  [self loadHTMLString:html baseURL:nil];
}


@end
