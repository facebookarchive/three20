/**
 * --
 */
#import <extThree20CSSStyle/extThree20CSSStyle.h>

@class TTGridViewRow;
@protocol TTGridViewDataSource

/**
 * --
 */
-(BOOL)gridView:(TTGridViewRow*)gridView isFlexibleTheColumnAtIndex:(NSInteger)anIndex;

/**
 * --
 */
-(CGFloat)gridView:(TTGridViewRow*)gridView widthForColumnAtIndex:(NSInteger)anIndex;

@optional

/**
 * --
 */
-(void)gridViewDidLoad:(TTGridViewRow*)gridView;

/**
 * --
 */
-(void)gridViewNeedsUpdate:(TTGridViewRow*)gridView;

/**
 * --
 */
-(UIView*)gridView:(TTGridViewRow*)gridView contentForColumnAtIndex:(NSInteger)anIndex;

/**
 * Return an formatted CSS Rule Set for specific column.
 */
-(TTCSSRuleSet*)gridView:(TTGridViewRow*)gridView cssRuleSetForColumnAtIndex:(NSInteger)anIndex;

/**
 * --
 */
-(NSInteger)numberOfColumnsForGridView:(TTGridViewRow*)gridView;

/**
 * --
 */
-(UIView*)gridView:(TTGridViewRow*)gridView contentForColumnAtIndex:(NSInteger)anIndex;

/**
 * --
 */
-(void)gridView:(TTGridViewRow*)gridView
orientationChanged:(UIInterfaceOrientation)newOrientation;

@end
