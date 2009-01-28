#import "Three20/T3Global.h"

@class T3URLCache;
@protocol T3URLRequestDelegate;

@interface T3URLRequest : NSObject {
  NSString* url;
  id<T3URLRequestDelegate> delegate;
  T3URLCache* cache;
  NSTimeInterval minTime;
  BOOL convertMedia;
}

@property(nonatomic, readonly) NSString* url;
@property(nonatomic, readonly) id<T3URLRequestDelegate> delegate;
@property(nonatomic, assign) T3URLCache* cache;
@property(nonatomic) NSTimeInterval minTime;
@property(nonatomic) BOOL convertMedia;

+ (T3URLRequest*)requestWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)delegate;

- (id)initWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)delegate;

/**
 * @return YES if the request was loaded synchronously from the cache.
 */
- (BOOL)send;

- (void)cancel;

@end

@protocol T3URLRequestDelegate <NSObject>

@optional
- (void)request:(T3URLRequest*)request loadingURL:(NSString*)url;
- (void)request:(T3URLRequest*)request loadedData:(NSData*)data media:(id)media 
  forURL:(NSString*)url;
- (void)request:(T3URLRequest*)request loadingURL:(NSString*)url didFailWithError:(NSError*)error;
- (void)request:(T3URLRequest*)request cancelledLoadingURL:(NSString*)url;

@end
