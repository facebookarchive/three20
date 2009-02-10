#import "Three20/T3Global.h"

@protocol T3URLRequestDelegate, T3URLResponseHandler;
@class T3URLCache;

@interface T3URLRequest : NSObject {
  NSString* _url;
  NSString* _httpMethod;
  NSData* _httpBody;
  NSString* _contentType;
  id<T3URLRequestDelegate> _delegate;
  id<T3URLResponseHandler> _handler;
  id _handlerDelegate;
  T3URLRequestCachePolicy _cachePolicy;
  NSTimeInterval _cacheExpirationAge;
  NSString* _cacheKey;
  NSDate* _timestamp;
  BOOL _loading;
  BOOL _canBeDelayed;
  BOOL _shouldHandleCookies;
  BOOL _shouldConvertToMedia;
  BOOL _responseFromCache;
}

/**
 * An object that receives messages about the progress of the request.
 */
@property(nonatomic,assign) id<T3URLRequestDelegate> delegate;

/**
 * An object that handles the response data and may parse and validate it.
 */
@property(nonatomic,retain) id<T3URLResponseHandler> handler;

/**
 * This delegate may be notified of any messages that are specific to the kind of response
 * that is received.  The handler may parse the response into certain objects and then
 * call methods on the handlerDelegate to receive them.
 */ 
@property(nonatomic,assign) id handlerDelegate;

@property(nonatomic,copy) NSString* url;
@property(nonatomic,copy) NSString* httpMethod;
@property(nonatomic,retain) NSData* httpBody;
@property(nonatomic,copy) NSString* contentType;
@property(nonatomic) T3URLRequestCachePolicy cachePolicy;
@property(nonatomic) NSTimeInterval cacheExpirationAge;
@property(nonatomic,retain) NSString* cacheKey;
@property(nonatomic,retain) NSDate* timestamp;
@property(nonatomic) BOOL loading;
@property(nonatomic) BOOL canBeDelayed;
@property(nonatomic) BOOL shouldHandleCookies;
@property(nonatomic) BOOL shouldConvertToMedia;
@property(nonatomic) BOOL responseFromCache;

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

@protocol T3URLResponseHandler <T3URLRequestDelegate>

/**
 * Processes the data from a successful request and determines if it is valid.
 *
 * If the data is not valid, return an error.  The data will not be cached if there is an error.
 */
- (NSError*)request:(T3URLRequest*)request validateData:(NSData*)data;

@end
