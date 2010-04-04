//
//  RootViewController.m
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright Brush The Dog Inc 2010. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

-(void)dealloc {
  
  [super dealloc];
}

-(id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
    self.title = @"Three20 NIB Demo";
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Root" style:UIBarButtonItemStyleBordered
                                     target:nil action:nil] autorelease];
    //self.tableViewStyle = UITableViewStyleGrouped;
  }
  return self;
}

- (void)createModel {
  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
       @"TTTableViewController",
       [TTTableTextItem itemWithText:@"Table No Nib" URL:@"tt://viewController/DemoTableViewController"],
       [TTTableTextItem itemWithText:@"Table with default NIB" URL:@"tt://nib/DemoTableViewController"],
       [TTTableTextItem itemWithText:@"Table with specific NIB" URL:@"tt://nib/FooterTableViewController/DemoTableViewController"],
       
       @"Other",
       [TTTableTextItem itemWithText:@"TTPostController" URL:@"tt://nib/DemoPostController"],
       [TTTableTextItem itemWithText:@"TTViewController" URL:@"tt://nib/DemoViewController"],
       
       [TTTableTextItem itemWithText:@"TTMessageController" URL:@"tt://modal/DemoMessageController"],
//       [TTTableTextItem itemWithText:@"TTWebController" URL:@"tt://g"],
//       [TTTableTextItem itemWithText:@"TTPopupViewController" URL:@"tt://h"],
//       
//       [TTTableTextItem itemWithText:@"TTPhotoViewController" URL:@"tt://i"],
//       [TTTableTextItem itemWithText:@"TTAlertViewController" URL:@"tt://k"],
//       [TTTableTextItem itemWithText:@"TTActionSheetController" URL:@"tt://viewController/TTActionSheetController"],
       
       nil];
}

@end

