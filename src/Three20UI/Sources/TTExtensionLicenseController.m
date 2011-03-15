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

#import "Three20UI/TTExtensionLicenseController.h"

// UI
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/TTStyledTextLabel.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTStyledText.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTLicense.h"
#import "Three20Core/TTLicenseInfo.h"
#import "Three20Core/TTExtensionInfo.h"
#import "Three20Core/TTExtensionAuthor.h"
#import "Three20Core/TTExtensionLoader.h"

static const CGFloat kFramePadding = 10;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTExtensionLicenseController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithExtensionID:(NSString*)identifier {
  self = [super initWithNibName:nil bundle:nil];
  if (nil != self) {
    _extensionInfo = [[[TTExtensionLoader availableExtensions] objectForKey:identifier] retain];

    self.title = [TTLicenseInfo nameForLicense:_extensionInfo.license];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithExtensionID:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_extensionInfo);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.view.backgroundColor = [UIColor whiteColor];

  NSString* preamble = [TTLicenseInfo preambleForLicense: _extensionInfo.license
                                   withCopyrightTimespan: _extensionInfo.copyrightTimespan
                                      withCopyrightOwner: _extensionInfo.copyrightOwner];

  _licensePreambleLabel = [[TTStyledTextLabel alloc] init];
  _licensePreambleLabel.text = [TTStyledText textWithURLs:preamble lineBreaks:YES];
  _licensePreambleLabel.backgroundColor = self.view.backgroundColor;

  _scrollView = [[UIScrollView alloc] init];
  _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                  | UIViewAutoresizingFlexibleHeight);
  _scrollView.frame = self.view.bounds;
  [_scrollView addSubview:_licensePreambleLabel];

  [self.view addSubview:_scrollView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  TT_RELEASE_SAFELY(_scrollView);
  TT_RELEASE_SAFELY(_licensePreambleLabel);

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _licensePreambleLabel.top = kFramePadding;
  _licensePreambleLabel.left = kFramePadding;
  _licensePreambleLabel.width = self.view.width - kFramePadding * 2;
  [_licensePreambleLabel sizeToFit];
  _scrollView.contentSize = CGSizeMake(self.view.width,
                                       _licensePreambleLabel.height + kFramePadding * 2);
}


@end
