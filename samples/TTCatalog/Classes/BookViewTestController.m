#import "BookViewTestController.h"
#import "MockPhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BookViewTestController

- (void)dealloc {
  _bookView.delegate = nil;
  _bookView.dataSource = nil;
  [_bookView release];
  [_colors release];
  [super dealloc];
}

- (void)loadView {
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
  CGRect frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - 44);
  self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
      
  _bookView = [[TTBookView alloc] initWithFrame:self.view.bounds];
  _bookView.dataSource = self;
  _bookView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:_bookView];
  
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
// TTBookViewDataSource

- (NSInteger)numberOfPagesInBookView:(TTBookView*)bookView {
  return _colors.count;
}

- (UIView*)bookView:(TTBookView*)bookView pageAtIndex:(NSInteger)pageIndex {
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

- (CGSize)bookView:(TTBookView*)bookView sizeOfPageAtIndex:(NSInteger)pageIndex {
  return CGSizeMake(320, 416);
}

@end
