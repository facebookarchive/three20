//
//  TTGridViewExampleViewController.h
//  TTGridViewExample
//

//

#import <UIKit/UIKit.h>
#import <extThree20GridView/TTGridViewRow.h>
#import <extThree20GridView/TTGridViewDataSource.h>
//#import <Three20UI/TTGridViewColumn.h>
//#import <Three20UI/TTGridViewColumnInterface.h>

@interface TTGridViewExampleViewController : UIViewController <TTGridViewDataSource> {
    TTGridViewRow *grid;

}

-(void)showHideColumn2:(id)sender;

-(void)showHideColumn4:(id)sender;

-(void)replaceColumn3:(id)sender;

@end

