#import "Three20/T3YouTubeView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kDefaultWidth = 140;
static CGFloat kDefaultHeight = 105;

static NSString* kEmbedHTML = @"<html><body style=\"margin:0\">\
<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
       width=\"%0.0f\" height=\"%0.0f\"></embed>\
</body></html>";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3YouTubeView

@synthesize url;

- (id)initWithURL:(NSString*)aURL {
  if (self = [self initWithFrame:CGRectMake(0, 0, kDefaultWidth, kDefaultHeight)]) {
    self.url = aURL;
  }
  return self;
}

- (void)dealloc {
  [url release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
    @"yt.width = %0.0f; yt.height = %0.0f", self.width, self.height]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setUrl:(NSString*)aURL {
  [url release];
  url = [aURL copy];

  NSString* html = [NSString stringWithFormat:kEmbedHTML, url, self.width, self.height];
  [self loadHTMLString:html baseURL:nil];
}


@end
