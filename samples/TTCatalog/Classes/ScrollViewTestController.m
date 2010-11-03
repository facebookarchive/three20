#import "ScrollViewTestController.h"
#import "MockPhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ScrollViewTestController

- (void)dealloc {
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  TT_RELEASE_SAFELY(_scrollView);
  TT_RELEASE_SAFELY(_pageControl);
  TT_RELEASE_SAFELY(_colors);
  [super dealloc];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nil bundle:nil];
  if ( self ){
    _colors = [[NSArray arrayWithObjects:
                [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1],
                [UIColor blueColor],
                [UIColor redColor],
                [UIColor yellowColor],
                [UIColor orangeColor],
                [UIColor cyanColor],
                [UIColor purpleColor],
                [UIColor brownColor],
                [UIColor magentaColor],
                [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1],
                nil
                ] retain];
  }
  return self;
}

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - 44);
  self.view = [[[UIView alloc] initWithFrame:frame] autorelease];

  _pageControl = [[TTPageControl alloc] initWithFrame:CGRectMake(0,0, self.view.width, 20)];
  _pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _pageControl.backgroundColor = [UIColor grayColor];
  _pageControl.currentPage = 0;
  _pageControl.numberOfPages = [_colors count];
  [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:_pageControl];

  _scrollView = [[TTScrollView alloc] initWithFrame:CGRectMake(0,_pageControl.bottom, self.view.bounds.size.width, self.view.bounds.size.height - _pageControl.height - 5.f)];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _scrollView.dataSource = self;
  _scrollView.delegate = self;
  _scrollView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:_scrollView];


}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView {
  return _colors.count;
}

- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  TTView* pageView = nil;
  if (!pageView) {
    pageView = [[[TTView alloc] init] autorelease];
    pageView.backgroundColor = [UIColor clearColor];
    pageView.userInteractionEnabled = NO;
    //pageView.contentMode = UIViewContentModeLeft;
  }

  pageView.style =
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:30] next:
    [TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 10, 10, 10) next:
    [TTLinearGradientFillStyle styleWithColor1:[_colors objectAtIndex:pageIndex]
                               color2:[UIColor whiteColor] next:
    [TTSolidBorderStyle styleWithColor:[UIColor blueColor] width:1 next:
    nil]]]];

  return pageView;
}

- (CGSize)scrollView:(TTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  return CGSizeMake(320, 416);
}

#pragma mark -
#pragma mark TTScrollViewDelegate

- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  _pageControl.currentPage = pageIndex;
}

#pragma mark -
#pragma mark UIViewController overrides
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark -
#pragma mark TTPageControl

- (IBAction)changePage:(id)sender {
  int page = _pageControl.currentPage;
  [_scrollView setCenterPageIndex:page];
}

@end
