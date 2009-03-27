#import "Three20/TTGlobal.h"

@class TTStyleView;

@interface TTLinkView : UIControl {
  id _delegate;
  id _url;
  TTStyleView* _screenView;
  int _borderRadius;
}

@property(nonatomic,assign) id delegate;

/**
 * The object that will be navigated to when the control is touched.
 *
 * This can be a string or an object that whose type is registered with TTNavigationCenter.
 */
@property(nonatomic,retain) id url;

@property(nonatomic) int borderRadius;

@end
