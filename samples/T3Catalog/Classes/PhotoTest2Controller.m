#import "PhotoTest2Controller.h"
#import "MockPhotoSource.h"

@implementation PhotoTest2Controller

- (void)viewDidLoad {
  self.photoSource = [[MockPhotoSource alloc]
    initWithType:MockPhotoSourceNormal
    // initWithType:MockPhotoSourceDelayed
    // initWithType:MockPhotoSourceLoadError
    // initWithType:MockPhotoSourceDelayed|MockPhotoSourceLoadError
    photos:[[NSArray alloc] initWithObjects:
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],

    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3246/2957580101_33c799fc09_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3246/2957580101_d63ef56b15_t.jpg"
      size:CGSizeMake(960, 1280)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3048/2942420409_20910290e9_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3048/2942420409_9c442b07ea_t.jpg"
      size:CGSizeMake(1024, 684)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3239/2945308303_e692ebffe1_t.jpg"
      size:CGSizeMake(683, 1024)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3160/2949948250_161a3914c1_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3160/2949948250_22eeaa085a_t.jpg"
      size:CGSizeMake(1024, 678)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3017/2948109400_838ebc22ef_t.jpg"
      size:CGSizeMake(1024, 681)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_b.jpg"
      smallURL:@"http://farm4.static.flickr.com/3290/2958486604_d217d02a6a_t.jpg"
      size:CGSizeMake(2800, 1866)] autorelease],
    [[[MockPhoto alloc]
      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
      size:CGSizeMake(800, 533)] autorelease],
    nil
  ]

  photos2:nil
//  photos2:[[NSArray alloc] initWithObjects:
//    [[[MockPhoto alloc]
//      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
//      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
//      size:CGSizeMake(800, 533)] autorelease],
//    nil]
  ];
  self.photoSource.title = @"Flickr Photos";
}

@end
