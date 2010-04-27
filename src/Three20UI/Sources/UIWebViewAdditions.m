//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/UIWebViewAdditions.h"

// UI
#import "Three20UI/UIViewAdditions.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
@implementation UIWebView (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////////////////////////////////////////////
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
