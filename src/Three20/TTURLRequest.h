#import "Three20/TTGlobal.h"

@protocol TTURLRequestDelegate, TTURLResponseHandler;
@class TTURLCache;

@interface TTURLRequest : NSObject {
  NSString* _url;
  NSString* _httpMethod;
  NSData* _httpBody;
  NSMutableDictionary* _params;
  NSString* _contentType;
  id<TTURLRequestDelegate> _delegate;
  id<TTURLResponseHandler> _handler;
  id _handlerDelegate;
  TTURLRequestCachePolicy _cachePolicy;
  NSTimeInterval _cacheExpirationAge;
  NSString* _cacheKey;
  NSDate* _timestamp;
  BOOL _loading;
  BOOL _shouldHandleCookies;
  BOOL _shouldConvertToMedia;
  BOOL _responseFromCache;
}

/**
 * An object that receives messages about the progress of the request.
 */
@property(nonatomic,assign) id<TTURLRequestDelegate> delegate;

/**
 * An object that handles the response data and may parse and validate it.
 */
@property(nonatomic,retain) id<TTURLResponseHandler> handler;

/**
 * This delegate may be notified of any messages that are specific to the kind of response
 * that is received.  The handler may parse the response into certain objects and then
 * call methods on the handlerDelegate to receive them.
 */ 
@property(nonatomic,assign) id handlerDelegate;

@property(nonatomic,copy) NSString* url;

@property(nonatomic,copy) NSString* httpMethod;

@property(nonatomic,retain) NSData* httpBody;

@property(nonatomic,retain) NSDictionary* params;

@property(nonatomic,copy) NSString* contentType;

/**
 * Defaults to "any".
 */
@property(nonatomic) TTURLRequestCachePolicy cachePolicy;

@property(nonatomic) NSTimeInterval cacheExpirationAge;

@property(nonatomic,retain) NSString* cacheKey;

@property(nonatomic,retain) NSDate* timestamp;

@property(nonatomic) BOOL loading;

@property(nonatomic) BOOL shouldHandleCookies;

@property(nonatomic) BOOL shouldConvertToMedia;

@property(nonatomic) BOOL responseFromCache;

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
 * The request has loaded data and optionally converted it to a media object.
 *
 * If the request is served from the cache, the is the only delegate method that will be called.
 */
- (void)request:(TTURLRequest*)request loadedData:(NSData*)data media:(id)media;

/**
 *
 */
- (void)request:(TTURLRequest*)request didFailWithError:(NSError*)error;

/**
 *
 */
- (void)requestCancelled:(TTURLRequest*)request;

@end

@protocol TTURLResponseHandler <TTURLRequestDelegate>

/**
 * Processes the data from a successful request and determines if it is valid.
 *
 * If the data is not valid, return an error.  The data will not be cached if there is an error.
 */
- (NSError*)request:(TTURLRequest*)request validateData:(NSData*)data;

@end
