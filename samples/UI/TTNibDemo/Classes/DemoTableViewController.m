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

#import "DemoTableViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * This class can be called with a nib or without a nib. It can show an optional
 * table header and / or table footer.
 */
@implementation DemoTableViewController

@synthesize headerView = _headerView;
@synthesize footerView = _footerView;


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Called both for NIB inits and manual inits
 */
-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
  if (self = [super initWithNibName:nibName bundle:bundle]) {
    self.title = @"DemoTableViewController";
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle: @"Root"
                                      style: UIBarButtonItemStyleBordered
                                     target: nil
                                     action: nil] autorelease];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
  TT_RELEASE_SAFELY(_footerView);
  TT_RELEASE_SAFELY(_headerView);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.tableHeaderView = self.headerView;
  self.tableView.tableFooterView = self.footerView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
  NSString * nibString = nil;

  if (self.nibName) {
    nibString = [@"NIB: " stringByAppendingString:self.nibName];

  } else {
    nibString = @"Called without a NIB";
  }

  self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
    @"TTTableViewController",
    [TTTableTextItem itemWithText:@"This demonstates a table"],
    [TTTableTextItem itemWithText:nibString],

    nil];
}


@end
