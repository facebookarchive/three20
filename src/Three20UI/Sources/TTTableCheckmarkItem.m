//
//  TTTableCheckmarkItem.m
//  Three20UI
//
//  Created by Joseph Smith on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TTTableCheckmarkItem.h"
#import "Three20Core/TTCorePreprocessorMacros.h"

@implementation TTTableCheckmarkItem
@synthesize text, checked, delegate, selector;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    delegate = NULL;
    selector = NULL;

    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    if ((self = [super init]))
    {
        checked = NO;
    }

    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text {
    TTTableCheckmarkItem *item = [[self alloc] init];
    item.text = text;
    return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithText:(NSString*)text delegate:(id)delegate selector:(SEL)selector {
    TTTableCheckmarkItem *item = [[self alloc] init];
    item.text = text;
    item.delegate = delegate;
    item.selector = selector;
    return item;
}


#pragma mark -
#pragma mark NSCoding
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder*)decoder {
    if ((self = [super initWithCoder:decoder])) {
        self.text = [decoder decodeObjectForKey:@"text"];
        self.checked = [decoder decodeBoolForKey:@"checked"];
    }

    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeBool:self.checked forKey:@"checked"];
}


@end
