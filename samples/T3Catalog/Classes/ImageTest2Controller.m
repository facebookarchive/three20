
#import "ImageTest2Controller.h"
#import "ImageTableViewCell.h"

@implementation ImageTest2Controller

- (void)viewDidLoad {
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

- (void)viewDidDisappear:(BOOL)animated {
  [T3URLCache sharedCache].paused = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ImageTableViewCell* cell = (ImageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"image"];
	if (cell == nil) {
		cell = [[[ImageTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"image"] autorelease];
	}

  cell.imageURL = [imageURLs objectAtIndex:indexPath.row % imageURLs.count];
  cell.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
	return cell;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [T3URLCache sharedCache].paused = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [T3URLCache sharedCache].paused = NO;
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [T3URLCache sharedCache].paused = NO;
}

- (BOOL)scrollViewWillScrollToTop:(UIScrollView *)scrollView {
  [T3URLCache sharedCache].paused = YES;
  return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [T3URLCache sharedCache].paused = NO;
}

@end

