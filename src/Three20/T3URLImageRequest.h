#import "Three20/T3URLRequest.h"

@protocol T3URLImageRequestDelegate;

@interface T3URLImageRequest : T3URLRequest {
}

@end

@protocol T3URLImageRequestDelegate <T3URLRequestDelegate>

@optional
- (void)cache:(T3URLCache*)cache loadedImage:(UIImage*)image forURL:(NSString*)url;

@end
