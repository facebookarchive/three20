// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/T3Global.h"

@class T3BackgroundView;

@interface T3LinkView : UIControl {
  id _delegate;
  id _href;
  T3BackgroundView* _screenView;
  int _borderRadius;
}

@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) id href;
@property(nonatomic) int borderRadius;

@end
