#import "Three20/TTGlobal.h"

@class TTView;

@interface TTLink : UIControl {
  id _url;
  TTView* _screenView;
}

/**
 * The object that will be navigated to when the control is touched.
 *
 * This can be a string or an object that whose type is registered with TTNavigationCenter.
 */
@property(nonatomic,retain) id url;

@end
