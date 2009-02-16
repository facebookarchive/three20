#import "Three20/TTGlobal.h"

@protocol TTSearchSource;
@class TTSearchTextField;

@interface TTSearchBar : UIView {
  TTSearchTextField* _searchField;
  UIColor* _tintColor;
}

@property(nonatomic,retain) id<TTSearchSource> searchSource;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic) BOOL showsDoneButton;
@property(nonatomic) BOOL showsDarkScreen;

@end
