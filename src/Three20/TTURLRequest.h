#import "Three20/TTGlobal.h"

@protocol TTURLRequestDelegate, TTURLResponse;

@interface TTURLRequest : NSObject {
  NSString* _URL;
  NSString* _httpMethod;
  NSData* _httpBody;
  NSMutableDictionary* _parameters;
  NSMutableDictionary* _headers;
  NSString* _contentType;
  NSMutableArray* _delegates;
  NSMutableArray* _files;
  id<TTURLResponse> _response;
  TTURLRequestCachePolicy _cachePolicy;
  NSTimeInterval _cacheExpirationAge;
  NSString* _cacheKey;
  NSDate* _timestamp;
  NSInteger _totalBytesLoaded;
  NSInteger _totalBytesExpected;
  id _userInfo;
  BOOL _isLoading;
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
@property(nonatomic,copy) NSString* URL;

/**
 * The HTTP method to send with the request.
 */
@property(nonatomic,copy) NSString* httpMethod;

/**
 * The HTTP body to send with the request.
 */
@property(nonatomic,retain) NSData* httpBody;

/**
 * The content type of the data in the request.
 */
@property(nonatomic,copy) NSString* contentType;

/**
 * Parameters to use for an HTTP post.
 */
@property(nonatomic,readonly) NSMutableDictionary* parameters;

/**
 * Custom HTTP headers.
 */
@property(nonatomic,readonly) NSMutableDictionary* headers;

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

@property(nonatomic) BOOL isLoading;

@property(nonatomic) BOOL shouldHandleCookies;

@property(nonatomic) NSInteger totalBytesLoaded;

@property(nonatomic) NSInteger totalBytesExpected;

@property(nonatomic) BOOL respondedFromCache;

+ (TTURLRequest*)request;

+ (TTURLRequest*)requestWithURL:(NSString*)URL delegate:(id<TTURLRequestDelegate>)delegate;

- (id)initWithURL:(NSString*)URL delegate:(id<TTURLRequestDelegate>)delegate;

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 * Adds a file whose data will be posted.
 */
- (void)addFile:(NSData*)data mimeType:(NSString*)mimeType fileName:(NSString*)fileName;

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

- (NSURLRequest*)createNSURLRequest;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTURLRequestDelegate <NSObject>

@optional

/**
 * The request has begun loading.
 */
- (void)requestDidStartLoad:(TTURLRequest*)request;

/**
 * The request has loaded some more data.
 *
 * Check the totalBytesLoaded and totalBytesExpected properties for details.
 */
- (void)requestDidUploadData:(TTURLRequest*)request;

/**
 * The request has loaded data has loaded and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestDidFinishLoad:(TTURLRequest*)request;

/**
 *
 */
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;

/**
 *
 */
- (void)requestDidCancelLoad:(TTURLRequest*)request;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * A helper class for storing user info to help identify a request.
 *
 * This class lets you store both a strong reference and a weak reference for the duration of
 * the request.  The weak reference is special because TTURLRequestQueue will examine it when
 * you call cancelRequestsWithDelegate to see if the weak object is the delegate in question.
 * For this reason, this object is a safe way to store an object that may be destroyed before
 * the request completes if you call cancelRequestsWithDelegate in the object's destructor.
 */
@interface TTUserInfo : NSObject {
  NSString* _topic;
  id _strong;
  id _weak;
}

@property(nonatomic,retain) NSString* topic;
@property(nonatomic,retain) id strong;
@property(nonatomic,assign) id weak;

+ (id)topic:(NSString*)topic strong:(id)strong weak:(id)weak;
+ (id)topic:(NSString*)topic;
+ (id)weak:(id)weak;

- (id)initWithTopic:(NSString*)topic strong:(id)strong weak:(id)weak;

@end
