#import "Three20/T3Global.h"

@protocol T3URLRequestDelegate;
@class T3URLCache;

@interface T3URLRequest : NSObject {
  NSString* url;
  id<T3URLRequestDelegate> delegate;
  NSTimeInterval minTime;
  BOOL convertMedia;
}

@property(nonatomic,readonly) id<T3URLRequestDelegate> delegate;
@property(nonatomic,readonly) NSString* url;
@property(nonatomic) NSTimeInterval minTime;
@property(nonatomic) BOOL convertMedia;

+ (T3URLRequest*)requestWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)delegate;

- (id)initWithURL:(NSString*)url delegate:(id<T3URLRequestDelegate>)delegate;

/**
 * Attempts to send a request.
 *
 * If the request can be resolved by the cache, it will happen synchronously.  Otherwise,
 * the request will respond to its delegate asynchronously.
 *
 * @return YES if the request was loaded synchronously from the cache.
 */
- (BOOL)send;

/**
 * Cancels the request.
 *
 * If there are multiple requests going to the same URL as this request, the others will
 * not be cancelled.
 */
- (void)cancel;

@end

@protocol T3URLRequestDelegate <NSObject>

@optional

/**
 * The request has been posted but not necessarily sent to the network yet.
 *
 * If the request is served from the cache, this method will not be called.
 */
- (void)requestPosted:(T3URLRequest*)request;

/**
 * The request has connected to the server and loading has begun.
 */
- (void)requestLoading:(T3URLRequest*)request;

/**
 * The request has loaded data and optionally converted it to a media object.
 *
 * If the request is served from the cache, the is the only delegate method that will be called.
 */
- (void)request:(T3URLRequest*)request loadedData:(NSData*)data media:(id)media;

/**
 *
 */
- (void)request:(T3URLRequest*)request didFailWithError:(NSError*)error;

/**
 *
 */
- (void)requestCancelled:(T3URLRequest*)request;

@end
