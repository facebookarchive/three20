#import "ScrollViewTestController.h"
#import "MockPhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ScrollViewTestController

- (void)dealloc {
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  [_scrollView release];
  [_colors release];
  [super dealloc];
}

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - 44);
  self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
      
  _scrollView = [[TTScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.dataSource = self;
  _scrollView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:_scrollView];
  
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView {
  return _colors.count;
}

- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  TTBackgroundView* pageView = nil;
  if (!pageView) {
    pageView = [[[TTBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
    pageView.style = TTDrawFillRect;
    pageView.backgroundInset = UIEdgeInsetsMake(10, 10, 10, 10);
    pageView.strokeRadius = 30;
    pageView.strokeColor = [UIColor blueColor];
    pageView.fillColor2 = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    pageView.backgroundColor = [UIColor clearColor];
    pageView.userInteractionEnabled = NO;
  }

  pageView.fillColor = [_colors objectAtIndex:pageIndex];
  
  return pageView;
}

- (CGSize)scrollView:(TTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  return CGSizeMake(320, 416);
}

@end
