/**
 *
 *
 */
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"
#import "Three20UI/Three20UI+Additions.h"
#import "extThree20CSSStyle/extThree20CSSStyle+Additions.h"
#import "TTGridViewRow.h"
#import "TTGridViewColumn.h"

@implementation TTGridViewRow
@synthesize dataSource = _dataSource;
@synthesize contentInset = _contentInset;
@synthesize currentOrientation;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        _containers = [[NSMutableArray alloc] init];
        _contents   = [[NSMutableArray alloc] init];
        _contentInset = UIEdgeInsetsZero;
        currentOrientation = TTInterfaceOrientation();
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+(id)initWithFrame:(CGRect)anFrame andDataSource:(id<TTGridViewDataSource>)anDataSource {
    TTGridViewRow* instance = [[[self alloc] initWithFrame:anFrame] autorelease];
    instance.dataSource = anDataSource;
    return instance;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Calc Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)howMuchFlexibleContainers {
    NSInteger total = 0;
    for (NSInteger i=0; i < [_containers count]; i++) {
        // Only calculate visible columns.
        if ( [self isVisibleTheColumnAtIndex:i] )
            total += [_dataSource gridView:self isFlexibleTheColumnAtIndex:i] ? 1 : 0;
    }
    return total;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)howMuchFixedContainers {
    return [_containers count] - [self howMuchFlexibleContainers];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)widthFixedContainers {
    CGFloat width = 0.0;

    for (NSInteger i=0; i < [_containers count]; i++) {
        // Only calculate visible columns.
        if ( [self isVisibleTheColumnAtIndex:i] ) {
            if ( ![_dataSource gridView:self isFlexibleTheColumnAtIndex:i] ) {
                width += [_dataSource gridView:self widthForColumnAtIndex:i];
            }
        }
    }

    return width;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)whatIsTheFlexibleSize {
    return ( ( self.frame.size.width - _contentInset.left - _contentInset.right )
                    - [self widthFixedContainers]) / [self howMuchFlexibleContainers];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Get & Set Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<TTGridViewDataSource>)dataSource {
    // First time?
    if ( _dataSource == nil ) {
        _dataSource = [(id)dataSource retain];
        ////
        // Did load.
        if (  [(id)_dataSource respondsToSelector:@selector(gridViewDidLoad:)] )
        {
            [_dataSource gridViewDidLoad:self];
        }
    }
    // Update..
    else if ( dataSource != _dataSource ) {
        [_dataSource release];
        _dataSource = [(id)dataSource retain];
    }
    // Needs update.
    [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    self.contentInset = contentInset;
    _shouldAnimateReLayout = animated;
    [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Layout Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)layoutContainerAtIndex:(NSInteger)anIndex withLeftPosition:(CGFloat)left {
    UIView *anContainer = [_containers objectAtIndex:anIndex] ;

    // Width.
    anContainer.width = [_dataSource gridView:self isFlexibleTheColumnAtIndex:anIndex]
                                ? flexibleSize
                                : [_dataSource gridView:self widthForColumnAtIndex:anIndex];
    // Position.
    anContainer.left = roundf(left);

    // Content alignment.
    if ( [(id)_dataSource respondsToSelector:@selector(gridView:cssRuleSetForColumnAtIndex:)] ) {
        // Retrieve the rule set.
        TTCSSRuleSet *ruleSet = [_dataSource gridView:self cssRuleSetForColumnAtIndex:anIndex];
        // Content.
        UIView *content = [self contentForColumn:anIndex];

        ///////////////////////
        // Vertical.
        if ([ruleSet.vertical_align isEqualToString:@"top"]) {
            content.top = _contentInset.top;
        }
        else if ([ruleSet.vertical_align isEqualToString:@"middle"]) {
            NSLog(@"centerY: %f", roundf( anContainer.height / 2.0f ));
            if ( roundf( anContainer.height / 2.0f ) == 0.00) {
                NSLog(@"Stop!");
            }
            CGFloat valueA, valueB;
            valueA = anContainer.frame.size.height;
            valueB = 2.0;
            content.centerY = valueA / valueB;//roundf( );
        }
        else if ([ruleSet.vertical_align isEqualToString:@"bottom"]) {
            content.bottom = roundf(anContainer.bottom);
        }

        /////////////
        // Horizontal.
        if ( [ruleSet.margin_right isEqualToString:@"auto"] &&
            ![ruleSet.margin_left isEqualToString:@"auto"]) {
            content.left = 0;
        }
        else if ([ruleSet.margin_right isEqualToString:@"auto"] &&
                 [ruleSet.margin_left isEqualToString:@"auto"]) {
            content.centerX = roundf( anContainer.width / 2.0f );
        }
        else if (![ruleSet.margin_right isEqualToString:@"auto"] &&
                  [ruleSet.margin_left isEqualToString:@"auto"]) {
            content.right = roundf(anContainer.width);
        }
    }
    // Return processed.
    return anContainer;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)orientationChanged:(UIInterfaceOrientation)newOrientation {
    currentOrientation = newOrientation;
    if ([(id)_dataSource respondsToSelector:@selector(gridView:orientationChanged:)] ) {
        [_dataSource gridView:self orientationChanged:currentOrientation];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews {
	[super layoutSubviews];

    UIInterfaceOrientation newOrientation = TTInterfaceOrientation();
    // Change?
    if ( currentOrientation != newOrientation ) {
        [self orientationChanged:newOrientation];
    }
    [self gridNeedsUpdate];

    // Calculate flexible size.
    flexibleSize = [self whatIsTheFlexibleSize];

    // First container at 0.
    CGFloat leftPosition = _contentInset.left;

    // Animated?
    if ( _shouldAnimateReLayout ) {
        [UIView animateWithDuration:5 animations:nil];
        [UIView beginAnimations:@"TTGridViewRow" context:nil];
    }

    // Layout Elements.
    for (NSInteger i=0; i < [_containers count]; i++){

        // If is visible... Layout and update last position.
        if ( [self isVisibleTheColumnAtIndex:i] )
            leftPosition = [self layoutContainerAtIndex:i withLeftPosition:leftPosition].right;
    }


    // Animated?
    if ( _shouldAnimateReLayout ) {
        [UIView commitAnimations];
    }
    _shouldAnimateReLayout = NO;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods.
///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isVisibleTheColumnAtIndex:(NSInteger)anIndex {
    return [(TTGridViewColumn*)[_contents objectAtIndex:anIndex] isVisible];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)show:(BOOL)visible columnAtIndex:(NSInteger)anIndex {
    TTGridViewColumn *column = [_contents objectAtIndex:anIndex];

    // Only change if we have a real change.
    if (visible != column.visible) {
        column.visible = visible;

        // Retrieve container.
        UIView *anContainer = [_containers objectAtIndex:anIndex];

        // Show.
        if ( visible ) {
            [self addSubview:anContainer];
        }

        // Hide.
        else {
            [anContainer removeFromSuperview];
        }

        // Relayout.
        [self setNeedsLayout];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)gridNeedsUpdate {
    if (  [(id)_dataSource respondsToSelector:@selector(gridViewNeedsUpdate:)] ) {
        [_dataSource gridViewNeedsUpdate:self];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView*)contentForColumn:(NSInteger)anIndex {
    // Retrieve.
    TTGridViewColumn *anColumn = [_contents objectAtIndex:anIndex];
    return anColumn.content;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setContent:(UIView*)anView forColumnAtIndex:(NSInteger)anIndex {
    // Retrieve.
    TTGridViewColumn *anColumn = [_contents objectAtIndex:anIndex];
    UIView *anContainer        = [_containers objectAtIndex:anIndex];

    // Set the CSS style if available.
    if ( [(id)_dataSource respondsToSelector:@selector(gridView:cssRuleSetForColumnAtIndex:)] ) {
        [anContainer applyCssRules:[_dataSource gridView:self cssRuleSetForColumnAtIndex:anIndex]];
    }

    // Remove from screen.
    [anColumn.content removeFromSuperview];

    // Replace.
    anColumn.content = anView;

    // Put on screen.
    [anContainer addSubview:anView];

    // Relayout.
    [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addLastColumnWithContent:(UIView*)anView {
    // Retain the view.
    [anView retain];

    // Create container.
    UIView *anContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.width,self.height)];
    anContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleHeight;
    [_containers addObject:anContainer];

    // Set the CSS style if available.
    if ( [(id)_dataSource respondsToSelector:@selector(gridView:cssRuleSetForColumnAtIndex:)] ) {
        [anContainer applyCssRules:[_dataSource gridView:self
                              cssRuleSetForColumnAtIndex:[_contents count]-1]];
    }

    // Put on screen.
    [self addSubview:anContainer];

    // Create column data.
    TTGridViewColumn *anColumn = [[TTGridViewColumn initWithContent:anView] retain];
    [_contents addObject:anColumn];

    [anContainer addSubview:anColumn.content];

    // Relayout.
    [self setNeedsLayout];

    // Release all.
    [anView release]; [anContainer release]; [anColumn release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_dataSource release];
    [_containers release];
    [super dealloc];
}

@end
