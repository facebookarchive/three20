#import "TTURLXMLRPCResponse.h"
#import <Three20Network/TTURLRequest.h>
#import "XMLRPCResponse.h"

@implementation TTURLXMLRPCResponse


- (void)dealloc {
	TT_RELEASE_SAFELY(_rpcResponse);
	[super dealloc];	
}


- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response data:(id)data {
	_rpcResponse = [[XMLRPCResponse alloc] initWithData:data];
	if([_rpcResponse isFault]) {
		return [NSError errorWithDomain:
						[[NSURL URLWithString:request.urlPath] host]
															 code:[[_rpcResponse faultCode] intValue]
													 userInfo:[NSDictionary dictionaryWithObject:[_rpcResponse faultString] forKey:@"fault"]];
	}
	return nil;
	
}

- (NSString *)body { return [_rpcResponse body]; }
- (id)object { return [_rpcResponse object]; }

@end
