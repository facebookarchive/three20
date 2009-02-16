
#import "ImageTest2Controller.h"
#import "ImageTableViewCell.h"

@implementation ImageTest2Controller

- (id)init {
  if (self = [super init]) {
    imageURLs = [[NSArray alloc] initWithObjects:
      @"http://ecx.images-amazon.com/images/I/41WZ2SA9MXL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/61kJCUXbJcL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/51ew2Gt8XfL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/51HNJzq9L6L._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/61kf7tWTUoL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/51PrwPHighL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/617vLnxZ9jL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/4102AVDXS4L._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/41WT0H8RHHL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/511KZDNW1GL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/51ltArHi27L._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/415NG3SBHDL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/31TIYo%2BzR5L._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/519sCNd1qrL._SL160_AA115_.jpg",
      @"http://ecx.images-amazon.com/images/I/51pLRnH5RKL._SL160_AA115_.jpg",
      nil
    ];
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
    style:UITableViewStylePlain];
	self.tableView.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.dataSource = self;
  [self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ImageTableViewCell* cell =
    (ImageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"image"];
	if (cell == nil) {
		cell = [[[ImageTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"image"]
      autorelease];
	}

  cell.imageURL = [imageURLs objectAtIndex:indexPath.row % imageURLs.count];
  cell.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
	return cell;
}

@end

