
#import "ImageTest2Controller.h"

@implementation ImageTest2Controller

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (TTImageTableField*)fieldForURL:(NSString*)url {
  return [[[TTIconTableField alloc] initWithText:@"Table Row" href:nil image:url
    defaultImage:[UIImage imageNamed:@"DefaultAlbum.png"]] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.rowHeight = 90;
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
  return [TTListDataSource dataSourceWithObjects:
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2266/2178246585_11d761324b_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2349/2179041484_f741b2bbe5_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2114/2178249889_bd17a48000_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2389/2179043790_317c14339f_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2148/2179047350_2ea15c0c10_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2055/2178254411_b945d90b0c_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2266/2178246585_11d761324b_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2349/2179041484_f741b2bbe5_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2114/2178249889_bd17a48000_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2389/2179043790_317c14339f_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2148/2179047350_2ea15c0c10_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2055/2178254411_b945d90b0c_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2266/2178246585_11d761324b_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2349/2179041484_f741b2bbe5_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2114/2178249889_bd17a48000_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2389/2179043790_317c14339f_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2148/2179047350_2ea15c0c10_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_s.jpg"],
      [self fieldForURL:@"http://farm3.static.flickr.com/2055/2178254411_b945d90b0c_s.jpg"],
      nil];
}

@end

