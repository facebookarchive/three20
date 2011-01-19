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

#import "TableWithBannerController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TableWithBannerController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void) createModel {
  //add enough items to see changes for content and scrollindicator insets
  self.dataSource =
  [TTListDataSource dataSourceWithObjects:
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   [TTTableTextItem itemWithText:@"Table Item"],
   nil];
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *bannerItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle Banner" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleBanner)];
  self.navigationItem.rightBarButtonItem = bannerItem;
  [bannerItem release];
}

- (void) toggleBanner {
  if(self.tableBannerView) {
    [self setTableBannerView:nil animated:YES];
  } else {
    //bannerview is adjusted by the TTTableView. it takes the full width
    //and gets its height from TTStyleSheet
    TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectZero];
    [self setTableBannerView:imageView animated:YES];
    [imageView release];
  }
}
@end

