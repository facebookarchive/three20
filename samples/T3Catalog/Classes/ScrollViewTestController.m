#import "ScrollViewTestController.h"

@implementation ScrollViewTestController

- (void)dealloc {
  [_scrollView release];
  [colors release];
  [super dealloc];
}

- (void)loadView {
  self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
      
  _scrollView = [[T3ScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  [self.view addSubview:_scrollView];
  
  colors = [[NSArray arrayWithObjects:
    [UIColor darkGrayColor],
    [UIColor blueColor],
    [UIColor redColor],
    [UIColor yellowColor],
    [UIColor orangeColor],
    [UIColor cyanColor],
    [UIColor purpleColor],
    [UIColor brownColor],
    [UIColor magentaColor],
    [UIColor lightGrayColor],
    nil
  ] retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ScrollViewDataSource

- (NSInteger)numberOfItemsInScrollView:(T3ScrollView*)scrollView {
  return 10;
}

- (UIView*)scrollView:(T3ScrollView*)scrollView pageAtIndex:(NSInteger)index {
  UIView* pageView = [_scrollView dequeueReusablePage];
  if (!pageView) {
    pageView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  }

  pageView.backgroundColor = [colors objectAtIndex:index];
  
  return pageView;
}

@end
