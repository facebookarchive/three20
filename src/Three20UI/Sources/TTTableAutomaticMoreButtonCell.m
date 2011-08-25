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


#import "Three20UI/TTTableAutomaticMoreButtonCell.h"

#import "Three20UI/TTTableAutomaticMoreButton.h"

// NETWORK
#import "Three20Network/Three20Network.h"

// UI
#import "Three20UI/TTTableMoreButton.h"
#import "Three20UI/UIViewAdditions.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


@implementation TTTableAutomaticMoreButtonCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    if (_item != object) {
        [super setObject:object];
        TTTableAutomaticMoreButton* item = object;
        self.animating = item.isLoading;
        self.textLabel.textColor = TTSTYLEVAR(moreLinkTextColor);
        self.selectionStyle = TTSTYLEVAR(tableSelectionStyle);
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    TTTableAutomaticMoreButton* moreLink = self.object;
    if(moreLink.isLoading == YES) {
        NSLog(@"zaten yükleme var");
        return;
    }
    
    if (moreLink.model) {
        moreLink.isLoading = YES;
        self.animating = YES;
        [moreLink.model load:TTURLRequestCachePolicyDefault more:YES];
    } 
}

@end
