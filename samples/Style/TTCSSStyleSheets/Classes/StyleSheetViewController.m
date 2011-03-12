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
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    TTDefaultCSSStyleSheet *_styleSheet = [[[TTDefaultCSSStyleSheet alloc] init] autorelease];
    _loadedSuccessfully = [_styleSheet
                           addStyleSheetFromDisk:TTPathForBundleResource(@"stylesheet.css")];
    [TTStyleSheet setGlobalStyleSheet:_styleSheet];
  }

  return self;
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

  self.view.backgroundColor = TTCSS(@"body", backgroundColor);
  UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  headerLabel.text = @"Header text";
  headerLabel.font            = TTCSS(@"h1", font);
  headerLabel.textColor       = TTCSS(@"h1", color);
  headerLabel.backgroundColor = TTCSS(@"h1", backgroundColor);
  headerLabel.shadowColor     = TTCSS(@"h1", shadowColor);
  headerLabel.shadowOffset    = TTCSS(@"h1", shadowOffset);
  [headerLabel sizeToFit];
  [self.view addSubview:headerLabel];
  TT_RELEASE_SAFELY(headerLabel);
}


@end

