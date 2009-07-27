#import "PhotoTest1Controller.h"
#import "MockPhotoSource.h"

@implementation PhotoTest1Controller

- (void)viewDidLoad {
  self.photoSource = [[[MockPhotoSource alloc]
    initWithType:MockPhotoSourceNormal
    //initWithType:MockPhotoSourceDelayed
    // initWithType:MockPhotoSourceLoadError
    // initWithType:MockPhotoSourceDelayed|MockPhotoSourceLoadError
    title:@"Flickr Photos"
    photos:[NSArray arrayWithObjects:
    // Request fails immediately due to DNS error
//    [[[MockPhoto alloc]
//      initWithURL:@"http://example.com"
//      smallURL:@"http://example.com"
//      size:CGSizeMake(320, 480)] autorelease],

    // 404 on both URL and thumbnail
//    [[[MockPhoto alloc]
//      initWithURL:@"http://farm4.static.flickr.com/3425/3214x620333_daf56d25e5.jpg?v=0"
//      smallURL:@"http://farm4.static.flickr.com/3425/3214620333_daf56d25e5_t.jpg"
//      size:CGSizeMake(320, 480)] autorelease],

    // Returns HTML instead of image
//    [[[MockPhoto alloc]
//      initWithURL:@"http://flickr.com"
//      smallURL:@"http://farm4.static.flickr.com/3444/3223645618_f5e2fa7fea_t.jpg"
//      size:CGSizeMake(320, 480)] autorelease],    

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3099/3164979221_6c0e583f7d.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3099/3164979221_6c0e583f7d_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3444/3223645618_13fe36887a_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3444/3223645618_f5e2fa7fea_t.jpg"
      size:CGSizeMake(320, 480)
      caption:@"This is a caption."] autorelease],

    // Uncomment to cause photo viewer to ask photo source to load itself
    // [NSNull null],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm2.static.flickr.com/1134/3172884000_84bc6a841e.jpg?v=0"
      smallURL:@"http://farm2.static.flickr.com/1134/3172884000_84bc6a841e_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm2.static.flickr.com/1124/3164979509_bcfdd72123.jpg?v=0"
      smallURL:@"http://farm2.static.flickr.com/1124/3164979509_bcfdd72123_t.jpg"
      size:CGSizeMake(320, 480)
      caption:@"A hike."] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3106/3203111597_d849ef615b.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3106/3203111597_d849ef615b_t.jpg"
      size:CGSizeMake(320, 480)
      caption:@"This is a really long caption to show how long captions are wrapped and \
truncated. This maximum number of lines is six, so captions have to be pretty \
darned verbose to get clipped.  I am probably going to suffer from a repetitive stress injury \
just from typing this! Are we truncated yet? Just a few more characters I guess."] autorelease],


    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3081/3164978791_3c292029f2.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3081/3164978791_3c292029f2_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm3.static.flickr.com/2358/2179913094_3a1591008e.jpg"
      smallURL:@"http://farm3.static.flickr.com/2358/2179913094_3a1591008e_t.jpg"
      size:CGSizeMake(383, 500)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3162/2677417507_e5d0007e41.jpg"
      smallURL:@"http://farm4.static.flickr.com/3162/2677417507_e5d0007e41_t.jpg"
      size:CGSizeMake(391, 500)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3334/3334095096_ffdce92fc4.jpg"
      smallURL:@"http://farm4.static.flickr.com/3334/3334095096_ffdce92fc4_t.jpg"
      size:CGSizeMake(407, 500)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3118/3122869991_c15255d889.jpg"
      smallURL:@"http://farm4.static.flickr.com/3118/3122869991_c15255d889_t.jpg"
      size:CGSizeMake(500, 406)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm2.static.flickr.com/1004/3174172875_1e7a34ccb7.jpg"
      smallURL:@"http://farm2.static.flickr.com/1004/3174172875_1e7a34ccb7_t.jpg"
      size:CGSizeMake(500, 372)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4.jpg"
      smallURL:@"http://farm3.static.flickr.com/2300/2179038972_65f1e5f8c4_t.jpg"
      size:CGSizeMake(391, 500)] autorelease],

    nil]

    photos2:nil
  ] autorelease];
}

@end
