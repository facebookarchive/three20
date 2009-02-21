#import "Three20/TTGlobal.h"

typedef enum {
  TTValid = 0,
  TTInvalid = 1,
  TTInvalidTemporarily = 2,
  TTInvalidForceReload = 4,
  TTInvalidError = 8,
  TTLoading = 16
} TTInvalidState;

@protocol TTObject <NSObject>

@property(nonatomic,readonly) NSString* viewURL;
@property(nonatomic) TTInvalidState invalid;

+ (id<TTObject>)fromURL:(NSURL*)url;

@end

