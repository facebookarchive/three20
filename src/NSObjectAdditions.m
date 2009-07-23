#import "Three20/TTNavigator.h"
#import "Three20/TTURLMap.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation NSObject (TTCategory)

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 withObject:(id)p5 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo setArgument:&p5 atIndex:6];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo setArgument:&p5 atIndex:6];
    [invo setArgument:&p6 atIndex:7];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (id)performSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 
    withObject:(id)p4 withObject:(id)p5 withObject:(id)p6 withObject:(id)p7 {
  NSMethodSignature *sig = [self methodSignatureForSelector:selector];
  if (sig) {
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    [invo setArgument:&p1 atIndex:2];
    [invo setArgument:&p2 atIndex:3];
    [invo setArgument:&p3 atIndex:4];
    [invo setArgument:&p4 atIndex:5];
    [invo setArgument:&p5 atIndex:6];
    [invo setArgument:&p6 atIndex:7];
    [invo setArgument:&p7 atIndex:8];
    [invo invoke];
    if (sig.methodReturnLength) {
      id anObject;
      [invo getReturnValue:&anObject];
      return anObject;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (NSString*)URLValue {
  return [[TTNavigator navigator].URLMap URLForObject:self];
}

- (NSString*)URLValueWithName:(NSString*)name {
  return [[TTNavigator navigator].URLMap URLForObject:self withName:name];
}

@end
