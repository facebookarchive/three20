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

#import "Three20Core/NSStringAdditions.h"

#import "Three20UI/TTTableMoreButtonCell.h"

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



static const CGFloat kMoreButtonMargin = 40;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableMoreButtonCell

@synthesize animating = _animating;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]) {
    self.textLabel.font = TTSTYLEVAR(tableSmallFont);
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_activityIndicatorView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return TT_ROW_HEIGHT*1.5;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
	[super layoutSubviews];
	
	BOOL hasDetailLabel = ((TTTableSubtitleItem*)_item).subtitle && ![((TTTableSubtitleItem*)_item).subtitle isEmptyOrWhitespace];
	
	[self.textLabel sizeToFit];
	
	CGFloat textWidth = self.textLabel.width;
	CGFloat cellWidth = self.contentView.width;
	CGFloat margin = 15.0;
	
	CGFloat textLeft = floor((cellWidth - textWidth)/2);
	CGFloat activityLeft =  textLeft - margin - _activityIndicatorView.width;
	
	CGFloat textLabelTop = self.textLabel.top;
    
	if (hasDetailLabel) {
		[self.detailTextLabel sizeToFit];
		textWidth =  MAX(textWidth, self.detailTextLabel.width);
	} else {
		textLabelTop = floor(self.contentView.height/2 - self.textLabel.height/2);
	}
    
	_activityIndicatorView.left = activityLeft;
	_activityIndicatorView.top = floor(self.contentView.height/2 - _activityIndicatorView.height/2);
	
	self.textLabel.frame = CGRectMake(textLeft,
									  textLabelTop,
									  textWidth,
									  self.textLabel.height);
	
	if (hasDetailLabel) {
		self.detailTextLabel.frame = CGRectMake(textLeft,
												self.textLabel.top + self.textLabel.height + 4,
												textWidth,
												self.detailTextLabel.height);
		self.detailTextLabel.textColor = TTSTYLEVAR(moreLinkTextColor);
		self.detailTextLabel.textAlignment = UITextAlignmentCenter;
		self.detailTextLabel.hidden = NO;
	} else {
		self.detailTextLabel.frame = CGRectZero;
		self.detailTextLabel.hidden = YES;
	}
    
	
	self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
	self.textLabel.textAlignment = UITextAlignmentCenter;
	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableMoreButton* item = object;
    self.animating = item.isLoading;

    self.textLabel.textColor = TTSTYLEVAR(moreLinkTextColor);
    self.selectionStyle = TTSTYLEVAR(tableSelectionStyle);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIActivityIndicatorView*)activityIndicatorView {
  if (!_activityIndicatorView) {
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_activityIndicatorView];
  }

  return _activityIndicatorView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAnimating:(BOOL)animating {
  if (_animating != animating) {
    _animating = animating;

    if (_animating) {
      [self.activityIndicatorView startAnimating];

    } else {
      [_activityIndicatorView stopAnimating];
    }

    [self setNeedsLayout];
  }
}


@end
