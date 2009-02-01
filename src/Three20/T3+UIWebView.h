#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIWebView (T3Category)

/**
 * Gets the frame of a DOM element in the page.
 *
 * @query A JavaScript expression that evaluates to a single DOM element.
 */
- (CGRect)frameOfElement:(NSString*)query;

@end
