//
//  TTURLBaseResponse.h
//  Three20Network
//
//  Created by Matěj Ornest on 2.6.11.
//  Copyright 2011 Mineus s.r.o. All rights reserved.
//

#import "TTURLResponse.h"

@interface TTURLBaseResponse : NSObject <TTURLResponse> {

	NSDictionary *_allHTTPHeaderFields;
}

@property (nonatomic, readonly, retain) NSDictionary *responseHeaders;

@end
