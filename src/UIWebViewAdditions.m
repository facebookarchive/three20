#import "Three20/TTGlobal.h"

@implementation UIWebView (TTCategory)

- (CGRect)frameOfElement:(NSString*)query {
  NSString* result = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"\
    var target = %@; \
    var x = 0, y = 0; \
    for (var n = target; n && n.nodeType == 1; n = n.offsetParent) {  \
      x += n.offsetLeft; \
      y += n.offsetTop; \
    } \
    x + ',' + y + ',' + target.offsetWidth + ',' + target.offsetHeight; \
", query]];
  
  NSArray* points = [result componentsSeparatedByString:@","];
  CGFloat x = [[points objectAtIndex:0] floatValue];
  CGFloat y = [[points objectAtIndex:1] floatValue];
  CGFloat width = [[points objectAtIndex:2] floatValue];
  CGFloat height = [[points objectAtIndex:3] floatValue];

  return CGRectMake(x, y, width, height);
}

#ifdef DEBUG
- (void)simulateTapElement:(NSString*)query {
  CGRect frame = [self.window convertRect:self.frame fromView:self.superview];
  CGRect pluginFrame = [self frameOfElement:query];
  CGPoint tapPoint = CGPointMake(
    frame.origin.x + pluginFrame.origin.x + pluginFrame.size.width/3,
    frame.origin.y + pluginFrame.origin.y + pluginFrame.size.height/3
  );
  [self simulateTapAtPoint:tapPoint];
}
#endif

@end
