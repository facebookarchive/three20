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

#import "extThree20JSON/SBJsonWriter.h"

@interface SBJsonWriter ()

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json;
- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json;
- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json;
- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json;

- (NSString*)indent;

@end

@implementation SBJsonWriter

@synthesize sortKeys;
@synthesize humanReadable;

static NSMutableCharacterSet *kEscapeChars;

+ (void)initialize {
	kEscapeChars = [[NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)] retain];
	[kEscapeChars addCharactersInString: @"\"\\"];
}

- (NSString*)stringWithObject:(id)value {
    [self clearErrorTrace];

    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
        depth = 0;
        NSMutableString *json = [NSMutableString stringWithCapacity:128];
        if ([self appendValue:value into:json])
            return json;
    }

    if ([value respondsToSelector:@selector(proxyForJson)]) {
        NSString *tmp = [self stringWithObject:[value proxyForJson]];
        if (tmp)
            return tmp;
    }

    [self addErrorWithCode:EFRAGMENT description:@"Not valid type for JSON"];
    return nil;
}

- (NSString*)stringWithObject:(id)value error:(NSError**)error {
    NSString *tmp = [self stringWithObject:value];
    if (tmp)
        return tmp;

    if (error)
        *error = [self.errorTrace lastObject];
    return nil;
}

- (NSString*)indent {
    return [@"\n" stringByPaddingToLength:1 + 2 * depth withString:@" " startingAtIndex:0];
}

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json {
    if ([fragment isKindOfClass:[NSDictionary class]]) {
        if (![self appendDictionary:fragment into:json])
            return NO;

    } else if ([fragment isKindOfClass:[NSArray class]]) {
        if (![self appendArray:fragment into:json])
            return NO;

    } else if ([fragment isKindOfClass:[NSString class]]) {
        if (![self appendString:fragment into:json])
            return NO;

    } else if ([fragment isKindOfClass:[NSNumber class]]) {
        if ('c' == *[fragment objCType]) {
            [json appendString:[fragment boolValue] ? @"true" : @"false"];
        } else if ([fragment isEqualToNumber:(NSNumber*)kCFNumberNaN]) {
            [self addErrorWithCode:EUNSUPPORTED description:@"NaN is not a valid number in JSON"];
            return NO;

        } else if (isinf([fragment doubleValue])) {
            [self addErrorWithCode:EUNSUPPORTED description:@"Infinity is not a valid number in JSON"];
            return NO;

        } else {
            [json appendString:[fragment stringValue]];
        }
    } else if ([fragment isKindOfClass:[NSNull class]]) {
        [json appendString:@"null"];
    } else if ([fragment respondsToSelector:@selector(proxyForJson)]) {
        [self appendValue:[fragment proxyForJson] into:json];

    } else {
        [self addErrorWithCode:EUNSUPPORTED description:[NSString stringWithFormat:@"JSON serialisation not supported for %@", [fragment class]]];
        return NO;
    }
    return YES;
}

- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json {
    if (maxDepth && ++depth > maxDepth) {
        [self addErrorWithCode:EDEPTH description: @"Nested too deep"];
        return NO;
    }
    [json appendString:@"["];

    BOOL addComma = NO;
    for (id value in fragment) {
        if (addComma)
            [json appendString:@","];
        else
            addComma = YES;

        if ([self humanReadable])
            [json appendString:[self indent]];

        if (![self appendValue:value into:json]) {
            return NO;
        }
    }

    depth--;
    if ([self humanReadable] && [fragment count])
        [json appendString:[self indent]];
    [json appendString:@"]"];
    return YES;
}

- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json {
    if (maxDepth && ++depth > maxDepth) {
        [self addErrorWithCode:EDEPTH description: @"Nested too deep"];
        return NO;
    }
    [json appendString:@"{"];

    NSString *colon = [self humanReadable] ? @" : " : @":";
    BOOL addComma = NO;
    NSArray *keys = [fragment allKeys];
    if (self.sortKeys)
        keys = [keys sortedArrayUsingSelector:@selector(compare:)];

    for (id value in keys) {
        if (addComma)
            [json appendString:@","];
        else
            addComma = YES;

        if ([self humanReadable])
            [json appendString:[self indent]];

        if (![value isKindOfClass:[NSString class]]) {
            [self addErrorWithCode:EUNSUPPORTED description: @"JSON object key must be string"];
            return NO;
        }

        if (![self appendString:value into:json])
            return NO;

        [json appendString:colon];
        if (![self appendValue:[fragment objectForKey:value] into:json]) {
            [self addErrorWithCode:EUNSUPPORTED description:[NSString stringWithFormat:@"Unsupported value for key %@ in object", value]];
            return NO;
        }
    }

    depth--;
    if ([self humanReadable] && [fragment count])
        [json appendString:[self indent]];
    [json appendString:@"}"];
    return YES;
}

- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json {

    [json appendString:@"\""];

    NSRange esc = [fragment rangeOfCharacterFromSet:kEscapeChars];
    if ( !esc.length ) {
        // No special chars -- can just add the raw string:
        [json appendString:fragment];

    } else {
        NSUInteger length = [fragment length];
        for (NSUInteger i = 0; i < length; i++) {
            unichar uc = [fragment characterAtIndex:i];
            switch (uc) {
                case '"':   [json appendString:@"\\\""];       break;
                case '\\':  [json appendString:@"\\\\"];       break;
                case '\t':  [json appendString:@"\\t"];        break;
                case '\n':  [json appendString:@"\\n"];        break;
                case '\r':  [json appendString:@"\\r"];        break;
                case '\b':  [json appendString:@"\\b"];        break;
                case '\f':  [json appendString:@"\\f"];        break;
                default:
                    if (uc < 0x20) {
                        [json appendFormat:@"\\u%04x", uc];
                    } else {
                        CFStringAppendCharacters((CFMutableStringRef)json, &uc, 1);
                    }
                    break;

            }
        }
    }

    [json appendString:@"\""];
    return YES;
}


@end
