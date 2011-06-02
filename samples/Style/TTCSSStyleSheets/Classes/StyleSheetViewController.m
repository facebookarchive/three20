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

#import "StyleSheetViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StyleSheetViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _styleSheet = [[TTCSSStyleSheet alloc] init];

    _loadedSuccessfully = [_styleSheet
                           loadFromFilename:TTPathForBundleResource(@"stylesheet.css")];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_styleSheet);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  if (!_loadedSuccessfully) {
    self.view.backgroundColor = [UIColor redColor];
    self.title = @"Failed to load";
    return;
  }

  self.title = @"Three20 CSS extension";

  self.view.backgroundColor = [_styleSheet backgroundColorWithCssSelector: @"body"
                                                                 forState: UIControlStateNormal];

  UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  headerLabel.text = @"Header text";
  headerLabel.font = [_styleSheet fontWithCssSelector:@"h1" forState:UIControlStateNormal];
  headerLabel.textColor = [_styleSheet colorWithCssSelector:@"h1" forState:UIControlStateNormal];
  headerLabel.backgroundColor = [_styleSheet backgroundColorWithCssSelector: @"h1"
                                                                   forState: UIControlStateNormal];
  headerLabel.shadowColor = [_styleSheet textShadowColorWithCssSelector: @"h1"
                                                               forState: UIControlStateNormal];
  headerLabel.shadowOffset = [_styleSheet textShadowOffsetWithCssSelector: @"h1"
                                                                 forState: UIControlStateNormal];
  [headerLabel sizeToFit];
  [self.view addSubview:headerLabel];
  TT_RELEASE_SAFELY(headerLabel);
}


@end

