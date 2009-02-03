#import "PhotoTest1Controller.h"
#import "MockPhotoSource.h"

@implementation PhotoTest1Controller

- (void)viewDidLoad {
  self.photoSource = [[MockPhotoSource alloc]
    initWithType:MockPhotoSourceNormal
    // initWithType:MockPhotoSourceDelayed
    // initWithType:MockPhotoSourceLoadError
    // initWithType:MockPhotoSourceDelayed|MockPhotoSourceLoadError
    title:@"Flickr Photos"
    photos:[[NSArray alloc] initWithObjects:

    // Request fails immediately due to DNS error
//    [[[MockPhoto alloc]
//      initWithURL:@"http://example.com"
//      smallURL:@"http://example.com"
//      size:CGSizeMake(320, 480)] autorelease],

    // 404 on both url and thumbnail
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
      initWithURL:@"http://farm4.static.flickr.com/3444/3223645618_13fe36887a_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3444/3223645618_f5e2fa7fea_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    // Causes album to be loaded
    [NSNull null],

    [[[MockPhoto alloc]
      initWithURL:@"http://photos-e.ll.facebook.com/photos-ll-sf2p/v646/35/54/223792/n223792_35094388_3743.jpg"
      smallURL:@"http://photos-e.ll.facebook.com/photos-ll-sf2p/v646/35/54/223792/t223792_35094388_3743.jpg"
      size:CGSizeMake(604, 453)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm2.static.flickr.com/1124/3164979509_bcfdd72123.jpg?v=0"
      smallURL:@"http://farm2.static.flickr.com/1124/3164979509_bcfdd72123_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3106/3203111597_d849ef615b.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3106/3203111597_d849ef615b_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3099/3164979221_6c0e583f7d.jpg?v=0"
      smallURL:@"http://farm4.static.flickr.com/3099/3164979221_6c0e583f7d_t.jpg"
      size:CGSizeMake(320, 480)] autorelease],

    nil
  ]

  photos2:nil
//  photos2:[[NSArray alloc] initWithObjects:
//    [[[MockPhoto alloc]
//      initWithURL:@"http://farm4.static.flickr.com/3081/3164978791_3c292029f2.jpg?v=0"
//      smallURL:@"http://farm4.static.flickr.com/3081/3164978791_3c292029f2_t.jpg"
//      size:CGSizeMake(320, 480)] autorelease],
//
//    [[[MockPhoto alloc]
//      initWithURL:@"http://farm2.static.flickr.com/1134/3172884000_84bc6a841e.jpg?v=0"
//      smallURL:@"http://farm2.static.flickr.com/1134/3172884000_84bc6a841e_t.jpg"
//      size:CGSizeMake(320, 480)] autorelease],
//    nil
//  ]
  ];
}

@end
