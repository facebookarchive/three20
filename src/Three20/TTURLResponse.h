#import "Three20/TTGlobal.h"

@class TTURLRequest;

@protocol TTURLResponse <NSObject>

/**
 * Processes the data from a successful request and determines if it is valid.
 *
 * If the data is not valid, return an error.  The data will not be cached if there is an error.
 */
- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
  data:(NSData*)data;

@end

@interface TTURLDataResponse : NSObject <TTURLResponse> {
  NSData* _data;
}

@property(nonatomic,readonly) NSData* data;

@end

@interface TTURLImageResponse : NSObject <TTURLResponse> {
  UIImage* _image;
}

@property(nonatomic,readonly) UIImage* image;

@end
