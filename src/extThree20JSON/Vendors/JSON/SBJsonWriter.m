/*
 Copyright (C) 2009 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SBJsonWriter.h"
#import "SBJsonStreamWriter.h"

@implementation SBJsonWriter

@synthesize sortKeys;
@synthesize humanReadable;

@synthesize error;
@synthesize maxDepth;

- (id)init {
    self = [super init];
    if (self)
        self.maxDepth = 512;
    return self;
}

- (void)dealloc {
    [error release];
    [super dealloc];
}

- (NSString*)stringWithObject:(id)value {
	NSData *data = [self dataWithObject:value];
	if (data)
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return nil;
}	

- (NSString*)stringWithObject:(id)value error:(NSError**)error_ {
    NSString *tmp = [self stringWithObject:value];
    if (tmp)
        return tmp;
    
    if (error_) {
		NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil];
        *error_ = [NSError errorWithDomain:@"org.brautaset.json.parser.ErrorDomain" code:0 userInfo:ui];
	}
	
    return nil;
}

- (NSData*)dataWithObject:(id)object {	
	SBJsonStreamWriter *streamWriter = [[[SBJsonStreamWriter alloc] init] autorelease];
	streamWriter.sortKeys = self.sortKeys;
	streamWriter.maxDepth = self.maxDepth;
	streamWriter.humanReadable = self.humanReadable;
	
	BOOL ok = NO;
	if ([object isKindOfClass:[NSDictionary class]])
		ok = [streamWriter writeObject:object];
	
	else if ([object isKindOfClass:[NSArray class]])
		ok = [streamWriter writeArray:object];
		
	else if ([object respondsToSelector:@selector(proxyForJson)])
		return [self dataWithObject:[object proxyForJson]];
	else {
		self.error = @"Not valid type for JSON";
		return nil;
	}
	
	if (ok)
		return streamWriter.data;
	
	self.error = streamWriter.error;
	return nil;	
}
	
	

@end
