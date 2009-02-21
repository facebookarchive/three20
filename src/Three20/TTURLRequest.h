#import "Three20/TTGlobal.h"

@protocol TTURLRequestDelegate, TTURLResponse;

@interface TTURLRequest : NSObject {
  NSString* _url;
  NSString* _httpMethod;
  NSData* _httpBody;
  NSMutableDictionary* _parameters;
  NSString* _contentType;
  NSMutableArray* _delegates;
  id<TTURLResponse> _response;
  TTURLRequestCachePolicy _cachePolicy;
  NSTimeInterval _cacheExpirationAge;
  NSString* _cacheKey;
  NSDate* _timestamp;
  id _userInfo;
  BOOL _loading;
  BOOL _shouldHandleCookies;
  BOOL _respondedFromCache;
}

/**
 * An object that receives messages about the progress of the request.
 */
@property(nonatomic,readonly) NSMutableArray* delegates;

/**
 * An object that handles the response data and may parse and validate it.
 */
@property(nonatomic,retain) id<TTURLResponse> response;

/**
 * The URL to be loaded by the request.
 */
@property(nonatomic,copy) NSString* url;

/**
 * The HTTP method to send with the request.
 */
@property(nonatomic,copy) NSString* httpMethod;

/**
 * The HTTP body to send with the request.
 */
@property(nonatomic,readonly) NSData* httpBody;

/**
 * The content type of the data in the request.
 */
@property(nonatomic,copy) NSString* contentType;

/**
 * Parameters to use for an HTTP post.
 */
@property(nonatomic,readonly) NSMutableDictionary* parameters;

/**
 * Defaults to "any".
 */
@property(nonatomic) TTURLRequestCachePolicy cachePolicy;

/**
 * The maximum age of cached data that can be used as a response.
 */
@property(nonatomic) NSTimeInterval cacheExpirationAge;

@property(nonatomic,retain) NSString* cacheKey;

@property(nonatomic,retain) id userInfo;

@property(nonatomic,retain) NSDate* timestamp;

@property(nonatomic) BOOL loading;

@property(nonatomic) BOOL shouldHandleCookies;

@property(nonatomic) BOOL respondedFromCache;

+ (TTURLRequest*)request;

+ (TTURLRequest*)requestWithURL:(NSString*)url delegate:(id<TTURLRequestDelegate>)delegate;

- (id)initWithURL:(NSString*)url delegate:(id<TTURLRequestDelegate>)delegate;

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

@protocol TTURLRequestDelegate <NSObject>

@optional

/**
 * The request has begun loading.
 */
- (void)requestLoading:(TTURLRequest*)request;

/**
 * The request has loaded data has loaded and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestLoaded:(TTURLRequest*)request;

/**
 *
 */
- (void)request:(TTURLRequest*)request didFailWithError:(NSError*)error;

/**
 *
 */
- (void)requestCancelled:(TTURLRequest*)request;

@end
