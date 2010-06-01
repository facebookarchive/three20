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

#import "extThree20CSSStyle/TTDefaultCSSStyleSheet.h"

// extThree20CSSStyle
#import "extThree20CSSStyle/TTCSSStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTGlobalCorePaths.h"

NSString* kDefaultCSSPath = @"extThree20CSSStyle.bundle/stylesheets/default.css";


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTDefaultCSSStyleSheet


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _styleSheet = [[TTCSSStyleSheet alloc] init];

    BOOL loadedSuccessfully = [_styleSheet
                               loadFromFilename:TTPathForBundleResource(kDefaultCSSPath)];

    TTDASSERT(loadedSuccessfully);
    if (!loadedSuccessfully) {
      // Bail out.
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_styleSheet);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)addStyleSheetFromDisk:(NSString*)filename {
  TTCSSStyleSheet* styleSheet = [[TTCSSStyleSheet alloc] init];

  BOOL loadedSuccessfully = [styleSheet loadFromFilename:filename];

  [_styleSheet addStyleSheet:styleSheet];

  TT_RELEASE_SAFELY(styleSheet);

  return loadedSuccessfully;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark iPhone OS system styles


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textColor {
  return [_styleSheet colorWithCssSelector: @"body"
                                  forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)highlightedTextColor {
  return [_styleSheet colorWithCssSelector: @"body"
                                  forState: UIControlStateHighlighted];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)backgroundColor {
  return [_styleSheet backgroundColorWithCssSelector: @"body"
                                            forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)navigationBarTintColor {
  return [_styleSheet backgroundColorWithCssSelector: @"navigationBar"
                                            forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Items


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)timestampTextColor {
  return [_styleSheet colorWithCssSelector: @".tableMessageItem"
                                  forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark DragRefreshHeader


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderLastUpdatedFont {
  return [_styleSheet fontWithCssSelector: @".dragRefreshHeaderLastUpdated"
                                 forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderStatusFont {
  return [_styleSheet fontWithCssSelector: @".dragRefreshHeaderStatusFont"
                                 forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderBackgroundColor {
  return [_styleSheet backgroundColorWithCssSelector: @".dragRefreshHeader"
                                            forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextColor {
  return [_styleSheet colorWithCssSelector: @".dragRefreshHeader"
                                  forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextShadowColor {
  return [_styleSheet textShadowColorWithCssSelector: @".dragRefreshHeader"
                                            forState: UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)tableRefreshHeaderTextShadowOffset {
  return [_styleSheet textShadowOffsetWithCssSelector: @".dragRefreshHeader"
                                             forState: UIControlStateNormal];
}


@end

