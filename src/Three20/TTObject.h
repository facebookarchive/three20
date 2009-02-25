#import "Three20/TTGlobal.h"

typedef enum {
  TTValid = 0,
  TTInvalid = 1,
  TTInvalidTemporarily = 2,
  TTInvalidForceReload = 4,
  TTInvalidError = 8,
  TTLoading = 16
} TTValidity;

@protocol TTObject <NSObject>

@property(nonatomic,readonly) NSString* viewURL;
@property(nonatomic) TTValidity invalid;

+ (id<TTObject>)fromURL:(NSURL*)url;

@end

