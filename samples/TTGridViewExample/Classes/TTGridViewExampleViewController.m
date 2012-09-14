//
//  extThree20GridViewSampleViewController.m
//  TTGridViewExample
//

#import "TTGridViewExampleViewController.h"

@implementation TTGridViewExampleViewController

////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// 
-(UIView*)contentForColumnAtIndex:(NSInteger)anIndex {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font     = [UIFont systemFontOfSize:11];
    label.backgroundColor = [UIColor redColor];
    
    switch (anIndex) {
        case 0:
            label.text = @"Column 1";
            //label.text = @"Month";
            break;
        case 1:
            label.text = @"Column 2";
            //label.text = @"Code";         
            break;
        case 2:
            label.text = @"Column 3";
            //            label.text = @"Last Trade";
            break;
        case 3:
            label.text = @"Column 4";
            //label.text = @"Last Position";
            break;
        case 4:
            label.text = @"Column 5";
            //            label.text = @"Last Delivery";
            break;
        case 5:
            label.text = @"Replaced";
            //            label.text = @"Last Delivery";
            break;
    }
    
    [label sizeToFit];
    
    return label;
    
}

////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// 
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an TTGridViewRow.
    grid = [[TTGridViewRow alloc] initWithFrame:CGRectMake(5, 0, 300, 30)];
    
    // Flexible Width.
    grid.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Grid background is white.
    //grid.backgroundColor = [UIColor grayColor];
    
    // Assign an Data Source.
    grid.dataSource = self;
    
    // Add columns content.
    [grid addLastColumnWithContent:[self contentForColumnAtIndex:0]];
    [grid addLastColumnWithContent:[self contentForColumnAtIndex:1]];
    [grid addLastColumnWithContent:[self contentForColumnAtIndex:2]];
    [grid addLastColumnWithContent:[self contentForColumnAtIndex:3]];
    [grid addLastColumnWithContent:[self contentForColumnAtIndex:4]];
    
    // Put on screen.
    [self.view addSubview:grid];
}

////////// ////////// ////////// ////////// /	///////// ////////// ////////// ////////// ////////// 
// Rotate, so we can see the Grid View strech and re layout his elements.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// 
#pragma mark TTGridViewDataSource

////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// 
-(BOOL)gridView:(TTGridViewRow*)gridView isFlexibleTheColumnAtIndex:(NSInteger)anIndex {

    switch (anIndex) {
        case 0:
            return NO;
            break;
        case 1:
            return NO;
            break;
        default:
            return YES;
            break;
    }
}

////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// 
-(CGFloat)gridView:(TTGridViewRow*)gridView widthForColumnAtIndex:(NSInteger)anIndex {
    switch (anIndex) {
        case 0:
            return 50;
            break;
        case 1:
            return 80;
            break;
        default:
            return 0;
            break;
    }
}


////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// ////////// 
// Return an formatted CSS Rule Set for specific column.
-(TTCSSRuleSet*)gridView:(TTGridViewRow*)gridView cssRuleSetForColumnAtIndex:(NSInteger)anIndex {
    TTCSSRuleSet *css = [TTCSSRuleSet initWithSelectorName:@"some"];
    
    css.color            = [UIColor redColor];
    css.background_color = [UIColor blueColor];
    css.vertical_align   = @"bottom";
    
    // Center the content.
    css.margin_left      = @"auto";
    css.margin_right     = @"auto";
    
    return css;
}

-(void)gridView:(TTGridViewRow*)gridView orientationChanged:(UIInterfaceOrientation)orientation {
    BOOL isVisible = !( orientation == UIInterfaceOrientationLandscapeLeft ||
                        orientation == UIInterfaceOrientationLandscapeRight );
    [gridView show:isVisible columnAtIndex:4];
}

-(void)showHideColumn2:(id)sender {
    BOOL isVisible = [grid isVisibleTheColumnAtIndex:1];
    [grid show:!isVisible columnAtIndex:1];
}

-(void)showHideColumn4:(id)sender {
    BOOL isVisible = [grid isVisibleTheColumnAtIndex:3];
    [grid show:!isVisible columnAtIndex:3];
}

-(void)replaceColumn3:(id)sender {
    [grid setContent:[self contentForColumnAtIndex:5] forColumnAtIndex:2];
}

- (void) dealloc {
    [super dealloc];
}

@end
