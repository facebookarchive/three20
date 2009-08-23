#import "Three20/TTButton.h"
#import "Three20/TTURLRequest.h"

@class TTLauncherItem, TTLabel;

@interface TTLauncherButton : TTButton <TTURLRequestDelegate> {
  TTLauncherItem* _item;
  UILabel* _titleLabel;
  UIImage* _image;
  TTLabel* _badge;
  TTButton* _closeButton;
  TTURLRequest* _imageRequest;
  BOOL _dragging;
  BOOL _editing;
}

@property(nonatomic,readonly) TTLauncherItem* item;
@property(nonatomic,readonly) TTButton* closeButton;
@property(nonatomic) BOOL dragging;
@property(nonatomic) BOOL editing;

- (id)initWithItem:(TTLauncherItem*)item;

@end
