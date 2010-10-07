#import "Three20Network/TTURLResponse.h"
@class XMLRPCResponse;
@interface TTURLXMLRPCResponse : NSObject <TTURLResponse> {
	XMLRPCResponse *_rpcResponse;
}

@property (nonatomic,readonly) id object;
@property (nonatomic,readonly) NSString *body;

@end
