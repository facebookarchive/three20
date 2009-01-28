#import "ScrollViewTestController.h"
#import "SamplePhotoSource.h"

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
  [self.view addSubview:_scrollView];
  
//  objects = [[NSArray arrayWithObjects:
//    [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1],
//    [UIColor blueColor],
//    [UIColor redColor],
//    [UIColor yellowColor],
//    [UIColor orangeColor],
//    [UIColor cyanColor],
//    [UIColor purpleColor],
//    [UIColor brownColor],
//    [UIColor magentaColor],
//    [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1],
//    nil
//  ] retain];

  objects = [[NSArray arrayWithObjects:
    [[[SamplePhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3444/3223645618_13fe36887a_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3444/3223645618_13fe36887a_o.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3425/3214620333_daf56d25e5.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3425/3214620333_daf56d25e5.jpg?v=0"
      size:CGSizeMake(320, 480)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://photos-e.ll.facebook.com/photos-ll-sf2p/v646/35/54/223792/n223792_35094388_3743.jpg"
      smallURL:@"http://photos-e.ll.facebook.com/photos-ll-sf2p/v646/35/54/223792/n223792_35094388_3743.jpg"
      size:CGSizeMake(604, 453)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://farm2.static.flickr.com/1124/3164979509_bcfdd72123.jpg?v=0"
      smallURL:@"http://farm2.static.flickr.com/1124/3164979509_bcfdd72123.jpg?v=0"
      size:CGSizeMake(320, 480)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3106/3203111597_d849ef615b.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3106/3203111597_d849ef615b.jpg?v=0"
      size:CGSizeMake(320, 480)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3099/3164979221_6c0e583f7d.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3099/3164979221_6c0e583f7d.jpg?v=0"
      size:CGSizeMake(320, 480)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3081/3164978791_3c292029f2.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3081/3164978791_3c292029f2.jpg?v=0"
      size:CGSizeMake(320, 480)] autorelease],

    [[[SamplePhoto alloc]
      initWithURL:@"http://farm2.static.flickr.com/1134/3172884000_84bc6a841e.jpg?v=0"
      smallURL:@"http://farm2.static.flickr.com/1134/3172884000_84bc6a841e.jpg?v=0"
      size:CGSizeMake(320, 480)] autorelease],
    nil
  ] retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3ScrollViewDataSource

- (NSInteger)numberOfItemsInScrollView:(T3ScrollView*)scrollView {
  return objects.count;
}

- (UIView*)scrollView:(T3ScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  T3ImageView* pageView = (T3ImageView*)[_scrollView dequeueReusablePage];
  if (!pageView) {
    pageView = [[[T3ImageView alloc] initWithFrame:CGRectZero] autorelease];
  }

  SamplePhoto* photo = [objects objectAtIndex:pageIndex];
  pageView.url = photo.url;

//  T3PaintedView* pageView = (T3PaintedView*)[_scrollView dequeueReusablePage];
//  if (!pageView) {
//    pageView = [[[T3PaintedView alloc] initWithFrame:CGRectZero] autorelease];
//    pageView.background = T3BackgroundRoundedRect;
//    pageView.strokeRadius = 30;
//    pageView.strokeColor = [UIColor whiteColor];
//    pageView.fillColor2 = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
//  }
//
//  pageView.fillColor = [objects objectAtIndex:pageIndex];
  
  return pageView;
}

- (CGSize)scrollView:(T3ScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  SamplePhoto* photo = [objects objectAtIndex:pageIndex];
  return photo.size;

//  return CGSizeMake(320, 416);
}

@end
