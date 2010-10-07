#import "Three20Network/TTURLRequest.h"
@class XMLRPCEncoder;
@interface TTURLXMLRPCRequest : TTURLRequest {
	XMLRPCEncoder *_encoder;
}

#pragma mark -

+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL delegate:(id)delegate;
+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL method:(NSString *)method delegate:(id)delegate;
+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL method:(NSString *)method parameters:(NSArray *)parameters delegate:(id)delegate;
+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL method:(NSString *)method parameter:(id)parameter delegate:(id)delegate;

#pragma mark -

- (id)initWithURL:(NSString *)URL method:(NSString *)method delegate:(id)delegate;
- (id)initWithURL:(NSString *)URL method:(NSString *)method parameters:(NSArray *)parameters delegate:(id)delegate;
- (id)initWithURL:(NSString *)URL method:(NSString *)method parameter:(id)parameter delegate:(id)delegate;


#pragma mark -

- (void)setMethod: (NSString *)method;
- (void)setMethod: (NSString *)method withParameter: (id)parameter;
- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;


#pragma mark -

- (NSString *)method;
- (NSArray *)parameters;

#pragma mark -

- (NSString *)body;

@end
