//
// Copyright 2009-2011 Facebook
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

#import "RootViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
  if (self = [super initWithNibName:nibName bundle:bundle]) {
    self.title = @"Three20 NIB Demo";
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle: @"Root"
                                      style: UIBarButtonItemStyleBordered
                                     target: nil
                                     action: nil] autorelease];
    //self.tableViewStyle = UITableViewStyleGrouped;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
//    [TTTableTextItem itemWithText:@"TTWebController" URL:@"tt://g"],
//    [TTTableTextItem itemWithText:@"TTPopupViewController" URL:@"tt://h"],
//
//    [TTTableTextItem itemWithText:@"TTPhotoViewController" URL:@"tt://i"],
//    [TTTableTextItem itemWithText:@"TTAlertViewController" URL:@"tt://k"],
//    [TTTableTextItem itemWithText:@"TTActionSheetController" URL:@"tt://viewController/TTActionSheetController"],

    nil];
}


@end

