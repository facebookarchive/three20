#import "ScrollViewTestController.h"
#import "MockPhotoSource.h"

@implementation ScrollViewTestController

- (void)dealloc {
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  [_scrollView release];
  [objects release];
  [super dealloc];
}

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - 44);
  self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
      
  _scrollView = [[T3ScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  _scrollView.backgroundColor = [UIColor blackColor];
  [self.view addSubview:_scrollView];
  
  objects = [[NSArray arrayWithObjects:
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
// T3ScrollViewDelegate

- (void)scrollView:(T3ScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(T3ScrollView*)scrollView {
  return objects.count;
}

- (UIView*)scrollView:(T3ScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  T3BackgroundView* pageView = (T3BackgroundView*)[_scrollView dequeueReusablePage];
  if (!pageView) {
    pageView = [[[T3BackgroundView alloc] initWithFrame:CGRectZero] autorelease];
    pageView.background = T3BackgroundRoundedRect;
    pageView.strokeRadius = 30;
    pageView.strokeColor = [UIColor whiteColor];
    pageView.fillColor2 = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
  }

  pageView.fillColor = [objects objectAtIndex:pageIndex];
  
  return pageView;
}

- (CGSize)scrollView:(T3ScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  return CGSizeMake(320, 416);
}

@end
