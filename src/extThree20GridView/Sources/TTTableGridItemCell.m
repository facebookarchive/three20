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
#import "TTTableGridItemCell.h"

// UI
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"

@implementation TTTableGridItemCell
@synthesize grid = _grid;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    if (self) {
        // Create an TTGridViewRow.
        _grid = [[TTGridViewRow alloc] initWithFrame:self.contentView.frame];
        // Flexible Width.
        _grid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // Grid background is transparent.
        _grid.backgroundColor = [UIColor clearColor];
        // Add to view.
        [self.contentView addSubview:_grid];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)prepareForReuse {
    [super prepareForReuse];
    [_grid setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    TT_RELEASE_SAFELY(_grid);
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    if (object != nil ) {
        [super setObject:object];
        TTTableGridItem* item = object;
        _grid.dataSource = item.dataSource;
    }
}

@end
