/**
 *
 *
 */
#import <UIKit/UIKit.h>
#import "TTGridViewDataSource.h"


@interface TTGridViewRow : UIView {
    id _dataSource;
    CGFloat flexibleSize;
    NSMutableArray *_containers;
    NSMutableArray *_contents;

    UIEdgeInsets _contentInset;
    UIInterfaceOrientation currentOrientation;

    BOOL _shouldAnimateReLayout;
}

/**
 * Current orientation.
 */
@property (assign) UIInterfaceOrientation currentOrientation;

/**
 * An TTGridViewDataSource implementation that provides the
 * data to construct the grid.
 */
@property (retain) id<TTGridViewDataSource> dataSource;

/**
 * The distance that the content view is inset from the
 * enclosing grid view. Use this property to add
 * an area around the content. The unit of size is points.
 * The default value is <tt>UIEdgeInsetsZero</tt>.
 */
@property (assign) UIEdgeInsets contentInset;

/**
 * The distance that the content view is inset from the
 * enclosing grid view. Use this property to add
 * an area around the content. The unit of size is points.
 * Allow define if the inset is animated or not.
 */
-(void)setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated;

/**
 * Init an TTGridViewRow object. Return an <tt>autoreleaseb</tt> instance.
 */
+(id)initWithFrame:(CGRect)anFrame andDataSource:(id<TTGridViewDataSource>)anDataSource;

/**
 * Show/Hide an specified column.
 */
-(void)show:(BOOL)visible columnAtIndex:(NSInteger)anIndex;

/**
 * Return YES if the specified column is visible.
 */
-(BOOL)isVisibleTheColumnAtIndex:(NSInteger)anIndex;

/**
 * Retrieve the content for the specified column.
 */
-(UIView*)contentForColumn:(NSInteger)anIndex;

/**
 * Set the internal content for the specified column.
 * The <tt>anView</tt> will be <b>retained</b>.
 */
-(void)setContent:(UIView*)anView forColumnAtIndex:(NSInteger)anIndex;

/**
 * Add a new column at the end of the grid and set his content.
 */
-(void)addLastColumnWithContent:(UIView*)anView;

/**
 * Force the grid to update his contents. Will ask the data
 * source in order to get the new content.
 */
-(void)gridNeedsUpdate;

@end
