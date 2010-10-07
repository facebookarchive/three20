#import "TTURLXMLRPCRequest.h"
#import "TTURLXMLRPCResponse.h"
#import "XMLRPCEncoder.h"
#import "Three20Core/NSStringAdditions.h"

@implementation TTURLXMLRPCRequest

#pragma mark -

- (NSString *)httpMethod  { return @"POST";     }
- (NSString *)contentType { return @"text/xml"; }
- (NSData *)httpBody { return [[self body] dataUsingEncoding:NSUTF8StringEncoding]; }

- (BOOL)send {
	if(!self.response)
		self.response = [[[TTURLXMLRPCResponse alloc] init] autorelease];
	return [super send];
}

#pragma mark -

+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL delegate:(id)delegate {
	return [[[self alloc] initWithURL:URL delegate:delegate] autorelease];
}

+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL method:(NSString *)method delegate:(id)delegate {
	return [[self alloc] initWithURL:URL method:method delegate:delegate];
	
}

+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL method:(NSString *)method parameters:(NSArray *)parameters delegate:(id)delegate {
	return [[self alloc] initWithURL:URL method:method parameters:parameters delegate:delegate];
}

+ (TTURLXMLRPCRequest *)requestWithURL:(NSString *)URL method:(NSString *)method parameter:(id)parameter delegate:(id)delegate {
	return [[self alloc] initWithURL:URL method:method parameter:parameter delegate:delegate];
}

#pragma mark -

- (id)init {
	if(self=[super init])	{
		_encoder = [[XMLRPCEncoder alloc] init];
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_encoder);
	[super dealloc];
}

- (id)initWithURL:(NSString *)URL method:(NSString *)method delegate:(id)delegate {
	if(self=[self initWithURL:URL delegate:delegate]) {
		[self setMethod:method];
	}
	return self;
}

- (id)initWithURL:(NSString *)URL method:(NSString *)method parameters:(NSArray *)parameters delegate:(id)delegate {
	if(self=[self initWithURL:URL delegate:delegate]) {
		[self setMethod:method withParameters:parameters];
	}
	return self;
}

- (id)initWithURL:(NSString *)URL method:(NSString *)method parameter:(id)parameter delegate:(id)delegate {
	if(self=[self initWithURL:URL delegate:delegate]) {
		[self setMethod:method withParameter:parameter];
	}
	return self;
}


#pragma mark -

- (void)setMethod: (NSString *)method {
	[_encoder setMethod:method withParameters:nil];
}

- (void)setMethod: (NSString *)method withParameter: (id)parameter {
	NSArray *parameters = nil;
	if(parameter)
		parameters = [NSArray arrayWithObject: parameter];
	[_encoder setMethod:method withParameters:parameters];
}

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters {
	[_encoder setMethod:method withParameters:parameters];
}

#pragma mark -

- (NSString *)method {
	return [_encoder method];
}

- (NSArray *)parameters {
	return [_encoder parameters];
}

#pragma mark -

- (NSString *)body {
	return [_encoder encode];
}


- (NSString*)generateCacheKey {
  return [[NSString stringWithFormat:@"%@#%@;body=%@",self.urlPath,[self method],[self body]] md5Hash];
}

@end
