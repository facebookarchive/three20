/**
 *
 *
 */
#import "TTGridViewColumn.h"


@implementation TTGridViewColumn
@synthesize content = _content;
@synthesize visible = _visible;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
    self = [super init];
    if (self != nil) {
        _visible = YES;
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)initWithContent:(UIView*)theContent {
    TTGridViewColumn *newContent = [[[self alloc] init] autorelease];
    newContent.content = theContent;
    return newContent;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
    [_content dealloc];
    [super dealloc];
}


@end
