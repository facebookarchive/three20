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

#import "Three20/TTTableHeaderDragRefreshView.h"

#import "Three20/TTGlobalCoreLocale.h"

#import "Three20/TTGlobalUI.h"
#import "Three20/TTURLCache.h"

#import "Three20/TTGlobalStyle.h"
#import "Three20/TTDefaultStyleSheet.h"

#import <QuartzCore/QuartzCore.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableHeaderDragRefreshView

@synthesize isFlipped = _isFlipped;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if(self = [super initWithFrame:frame]) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _lastUpdatedLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f,
                                                  frame.size.width, 20.0f)];
    _lastUpdatedLabel.autoresizingMask =
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _lastUpdatedLabel.font            = TTSTYLEVAR(tableRefreshHeaderLastUpdatedFont);
    _lastUpdatedLabel.textColor       = TTSTYLEVAR(tableRefreshHeaderTextColor);
    _lastUpdatedLabel.shadowColor     = TTSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _lastUpdatedLabel.shadowOffset    = TTSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    _lastUpdatedLabel.textAlignment   = UITextAlignmentCenter;
    [self addSubview:_lastUpdatedLabel];
    
    _statusLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f,
                                             frame.size.width, 20.0f )];
    _statusLabel.autoresizingMask =
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _statusLabel.font             = TTSTYLEVAR(tableRefreshHeaderStatusFont);
    _statusLabel.textColor        = TTSTYLEVAR(tableRefreshHeaderTextColor);
    _statusLabel.shadowColor      = TTSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _statusLabel.shadowOffset     = TTSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    _statusLabel.backgroundColor  = [UIColor clearColor];
    _statusLabel.textAlignment    = UITextAlignmentCenter;
    [self setStatus:TTTableHeaderDragRefreshPullToReload];
    [self addSubview:_statusLabel];
    
    _arrowImage = [[UIImageView alloc]
                   initWithFrame:CGRectMake(25.0f, frame.size.height - 65.0f,
                                            30.0f, 55.0f)];
    _arrowImage.contentMode       = UIViewContentModeScaleAspectFit;
    _arrowImage.image             = TTSTYLEVAR(tableRefreshHeaderArrowImage);
    [_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    [self addSubview:_arrowImage];
    
    _activityView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake( 25.0f, frame.size.height - 38.0f, 20.0f, 20.0f );
    _activityView.hidesWhenStopped  = YES;
    [self addSubview:_activityView];
    
    _isFlipped = NO;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_activityView);
  TT_RELEASE_SAFELY(_statusLabel);
  TT_RELEASE_SAFELY(_arrowImage);
  TT_RELEASE_SAFELY(_lastUpdatedLabel);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)flipImageAnimated:(BOOL)animated {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animated ? .18 : 0.0];
  [_arrowImage layer].transform = _isFlipped ?
    CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) :
    CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
  [UIView commitAnimations];
  
  _isFlipped = !_isFlipped;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUpdateDate:(NSDate*)newDate {
  if (newDate) {
    if (_lastUpdatedDate != newDate) {
      [_lastUpdatedDate release];
    }
    
    _lastUpdatedDate = [newDate retain];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    _lastUpdatedLabel.text = [NSString stringWithFormat:
                              TTLocalizedString(@"Last updated: %@",
                                                @"The last time the table view was updated."),
                              [formatter stringFromDate:_lastUpdatedDate]];
    [formatter release];
    
  } else {
    _lastUpdatedDate = nil;
    _lastUpdatedLabel.text = TTLocalizedString(@"Last updated: never",
                                               @"The table view has never been updated");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentDate {
  [self setUpdateDate:[NSDate date]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatus:(TTTableHeaderDragRefreshStatus)status {
  switch (status) {
    case TTTableHeaderDragRefreshReleaseToReload: {
      _statusLabel.text = TTLocalizedString(@"Release to update...",
                                            @"Release the table view to update the contents.");
      break;
    }
      
    case TTTableHeaderDragRefreshPullToReload: {
      _statusLabel.text = TTLocalizedString(@"Pull down to update...",
                                            @"Drag the table view down to update the contents.");
      break;
    }
      
    case TTTableHeaderDragRefreshLoadingStatus: {
      _statusLabel.text = TTLocalizedString(@"Updating...",
                                            @"Updating the contents of a table view.");
      break;
    }
      
    default: {
      break;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)shouldShow {
  if (shouldShow) {
    [_activityView startAnimating];
    _arrowImage.hidden = YES;
    [self setStatus:TTTableHeaderDragRefreshLoadingStatus];
    
  } else {
    [_activityView stopAnimating];
    _arrowImage.hidden = NO;
  }
  
}


@end
