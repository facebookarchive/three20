#import "Three20/TTGlobal.h"

@class TTView;

@interface TTLink : UIControl {
  id _URL;
  TTView* _screenView;
}

/**
 * The URL that will be loaded when the control is touched.
 */
@property(nonatomic,retain) id URL;

@end
