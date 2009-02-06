#import "Three20/T3Global.h"

typedef enum {
  T3Valid = 0,
  T3Invalid = 1,
  T3InvalidTemporarily = 2,
  T3InvalidForceReload = 4,
  T3InvalidError = 8,
  T3Loading = 16
} T3InvalidState;

@protocol T3Object <NSObject>

@property(nonatomic,readonly) NSString* viewURL;
@property(nonatomic) T3InvalidState isInvalid;

+ (id<T3Object>)fromURL:(NSURL*)url;

@end

