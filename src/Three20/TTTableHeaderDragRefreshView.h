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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
	TTTableHeaderDragRefreshReleaseToReload,
	TTTableHeaderDragRefreshPullToReload,
	TTTableHeaderDragRefreshLoadingStatus
} TTTableHeaderDragRefreshStatus;

/**
 * Pulled from the uprise78/three20-P31 fork with consent of uprise78.
 */
@interface TTTableHeaderDragRefreshView : UIView {
  NSDate*                   _lastUpdatedDate;
	UILabel*                  _lastUpdatedLabel;
	UILabel*                  _statusLabel;
	UIImageView*              _arrowImage;
	UIActivityIndicatorView*  _activityView;
  
	BOOL                      _isFlipped;
}

@property (nonatomic) BOOL isFlipped;

- (void)flipImageAnimated:(BOOL)animated;
- (void)setCurrentDate;
- (void)setUpdateDate:(NSDate*)date;
- (void)showActivity:(BOOL)shouldShow;
- (void)setStatus:(TTTableHeaderDragRefreshStatus)status;

@end
