#import "Three20/TTGlobal.h"

@class TTBackgroundView;

@interface TTLinkView : UIControl {
  id _delegate;
  id _href;
  TTBackgroundView* _screenView;
  int _borderRadius;
}

@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) id href;
@property(nonatomic) int borderRadius;

@end
