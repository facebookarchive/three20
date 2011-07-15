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

#import "SampleCSSStyleSheet.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StyleSheetViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    SampleCSSStyleSheet *_styleSheet = [[[SampleCSSStyleSheet alloc] init] autorelease];
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

  // Using helper macro
  UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  headerLabel.text = @"Header text";
  headerLabel.font            = TTCSS(@"h1", font);
  headerLabel.textColor       = TTCSS(@"h1", color);
  headerLabel.backgroundColor = TTCSS(@"h1", backgroundColor);
  headerLabel.shadowColor     = TTCSS(@"h1", shadowColor);
  headerLabel.shadowOffset    = TTCSS(@"h1", shadowOffset);
  [headerLabel sizeToFit];
  [self.view addSubview:headerLabel];

  // Using UILabel addition
  UILabel* headerLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
  headerLabel2.text = @"Header 2 text";
  [headerLabel2 applyCssSelector:@"h2"];
  [headerLabel2 sizeToFit];
  CGFloat top = headerLabel.frame.size.height;
  CGRect frame = headerLabel2.frame;
  frame.origin.y = top;
  headerLabel2.frame = frame;
  [self.view addSubview:headerLabel2];

  // Using TTTextStyle addition
  TTButton* headerLabel3 = [TTButton buttonWithStyle:@"h3:" title:@"Header 3 text"];
  [headerLabel3 sizeToFit];
  top += headerLabel2.frame.size.height;
  frame = headerLabel3.frame;
  frame.origin.y = top;
  headerLabel3.frame = frame;
  [self.view addSubview:headerLabel3];

  // Using TTTextStyle + TTShadowStyle addition
  TTButton* headerLabel4 = [TTButton buttonWithStyle:@"h4:" title:@"Header 4 text"];
  [headerLabel4 sizeToFit];
  top += headerLabel2.frame.size.height;
  frame = headerLabel4.frame;
  frame.origin.y = top;
  headerLabel4.frame = frame;
  [self.view addSubview:headerLabel4];

  TT_RELEASE_SAFELY(headerLabel);
  TT_RELEASE_SAFELY(headerLabel2);
}


@end

