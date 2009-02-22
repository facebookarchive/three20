#import "Three20/TTGlobal.h"

@implementation NSArray (TTCategory)

- (void)perform:(SEL)selector {
  NSEnumerator* e = [[[self copy] autorelease] objectEnumerator];
  for (id delegate; delegate = [e nextObject]; ) {
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector];
    }
  }
}

- (void)perform:(SEL)selector withObject:(id)p1 {
  NSEnumerator* e = [[[self copy] autorelease] objectEnumerator];
  for (id delegate; delegate = [e nextObject]; ) {
    if ([delegate respondsToSelector:selector]) {
      NSMethodSignature *sig = [delegate methodSignatureForSelector:selector];
      NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
      [invo setTarget:delegate];
      [invo setSelector:selector];
      [invo setArgument:&p1 atIndex:2];
      [invo invoke];
    }
  }
}

- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2 {
  NSEnumerator* e = [[[self copy] autorelease] objectEnumerator];
  for (id delegate; delegate = [e nextObject]; ) {
    if ([delegate respondsToSelector:selector]) {
      NSMethodSignature *sig = [delegate methodSignatureForSelector:selector];
      NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
      [invo setTarget:delegate];
      [invo setSelector:selector];
      [invo setArgument:&p1 atIndex:2];
      [invo setArgument:&p2 atIndex:3];
      [invo invoke];
    }
  }
}

- (void)perform:(SEL)selector withObject:(id)p1 withObject:(id)p2
    withObject:(id)p3 {
  NSEnumerator* e = [[[self copy] autorelease] objectEnumerator];
  for (id delegate; delegate = [e nextObject]; ) {
    if ([delegate respondsToSelector:selector]) {
      NSMethodSignature *sig = [delegate methodSignatureForSelector:selector];
      NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
      [invo setTarget:delegate];
      [invo setSelector:selector];
      [invo setArgument:&p1 atIndex:2];
      [invo setArgument:&p2 atIndex:3];
      [invo setArgument:&p3 atIndex:4];
      [invo invoke];
    }
  }
}

@end
