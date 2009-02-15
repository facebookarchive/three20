#import "Three20/T3Global.h"

@protocol T3SearchSource;

@interface T3SearchTextField : UITextField {
  id<T3SearchSource> _searchSource;
}

@property(nonatomic,retain) id<T3SearchSource> searchSource;

@end

@protocol T3SearchSource <NSObject>

@end
