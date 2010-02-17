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

#import "Three20/TTStyleSheet.h"

@class TTShape;

@interface TTDefaultStyleSheet : TTStyleSheet

@property(nonatomic,readonly) UIColor* textColor;
@property(nonatomic,readonly) UIColor* highlightedTextColor;
@property(nonatomic,readonly) UIColor* placeholderTextColor;
@property(nonatomic,readonly) UIColor* timestampTextColor;
@property(nonatomic,readonly) UIColor* linkTextColor;
@property(nonatomic,readonly) UIColor* moreLinkTextColor;
@property(nonatomic,readonly) UIColor* selectedTextColor;
@property(nonatomic,readonly) UIColor* photoCaptionTextColor;

@property(nonatomic,readonly) UIColor* navigationBarTintColor;
@property(nonatomic,readonly) UIColor* toolbarTintColor;
@property(nonatomic,readonly) UIColor* searchBarTintColor;
@property(nonatomic,readonly) UIColor* screenBackgroundColor;
@property(nonatomic,readonly) UIColor* backgroundColor;

@property(nonatomic,readonly) UIColor* tableActivityTextColor;
@property(nonatomic,readonly) UIColor* tableErrorTextColor;
@property(nonatomic,readonly) UIColor* tableSubTextColor;
@property(nonatomic,readonly) UIColor* tableTitleTextColor;
@property(nonatomic,readonly) UIColor* tableHeaderTextColor;
@property(nonatomic,readonly) UIColor* tableHeaderShadowColor;
@property(nonatomic,readonly) UIColor* tableHeaderTintColor;
@property(nonatomic,readonly) UIColor* tableSeparatorColor;
@property(nonatomic,readonly) UIColor* tablePlainBackgroundColor;
@property(nonatomic,readonly) UIColor* tableGroupedBackgroundColor;
@property(nonatomic,readonly) UIColor* searchTableBackgroundColor;
@property(nonatomic,readonly) UIColor* searchTableSeparatorColor;

// Table refresh header.
// Used in TTTableViewDragRefreshDelegate.h/m
@property(nonatomic,readonly) UIFont*  tableRefreshHeaderLastUpdatedFont;
@property(nonatomic,readonly) UIFont*  tableRefreshHeaderStatusFont;
@property(nonatomic,readonly) UIColor* tableRefreshHeaderBackgroundColor;
@property(nonatomic,readonly) UIColor* tableRefreshHeaderTextColor;
@property(nonatomic,readonly) UIColor* tableRefreshHeaderTextShadowColor;
@property(nonatomic,readonly) CGSize   tableRefreshHeaderTextShadowOffset;
@property(nonatomic,readonly) UIImage* tableRefreshHeaderArrowImage;


@property(nonatomic,readonly) UIColor* tabTintColor;
@property(nonatomic,readonly) UIColor* tabBarTintColor;

@property(nonatomic,readonly) UIColor* messageFieldTextColor;
@property(nonatomic,readonly) UIColor* messageFieldSeparatorColor;

@property(nonatomic,readonly) UIColor* thumbnailBackgroundColor;

@property(nonatomic,readonly) UIColor* postButtonColor;

@property(nonatomic,readonly) UIFont* font;
@property(nonatomic,readonly) UIFont* buttonFont;
@property(nonatomic,readonly) UIFont* tableFont;
@property(nonatomic,readonly) UIFont* tableSmallFont;
@property(nonatomic,readonly) UIFont* tableTitleFont;
@property(nonatomic,readonly) UIFont* tableTimestampFont;
@property(nonatomic,readonly) UIFont* tableButtonFont;
@property(nonatomic,readonly) UIFont* tableSummaryFont;
@property(nonatomic,readonly) UIFont* tableHeaderPlainFont;
@property(nonatomic,readonly) UIFont* tableHeaderGroupedFont;
@property(nonatomic,readonly) UIFont* photoCaptionFont;
@property(nonatomic,readonly) UIFont* messageFont;
@property(nonatomic,readonly) UIFont* errorTitleFont;
@property(nonatomic,readonly) UIFont* errorSubtitleFont;
@property(nonatomic,readonly) UIFont* activityLabelFont;
@property(nonatomic,readonly) UIFont* activityBannerFont;

@property(nonatomic,readonly) UITableViewCellSelectionStyle tableSelectionStyle;

- (TTStyle*)selectionFillStyle:(TTStyle*)next;

- (TTStyle*)toolbarButtonForState:(UIControlState)state shape:(TTShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font;

- (TTStyle*)pageDotWithColor:(UIColor*)color;

@end
