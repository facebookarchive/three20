/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTTableViewController.h"
#import "Three20/TTThumbsTableViewCell.h"
#import "Three20/TTPhotoSource.h"

@protocol TTThumbsViewControllerDelegate, TTPhotoSource;
@class TTPhotoViewController;

@interface TTThumbsViewController : TTTableViewController <TTThumbsTableViewCellDelegate> {
  id<TTThumbsViewControllerDelegate> _delegate;
  id<TTPhotoSource> _photoSource;
}

@property(nonatomic,assign) id<TTThumbsViewControllerDelegate> delegate;
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

- (id)initWithDelegate:(id<TTThumbsViewControllerDelegate>)delegate;
- (id)initWithQuery:(NSDictionary*)query;

- (TTPhotoViewController*)createPhotoViewController;
- (id<TTTableViewDataSource>)createDataSource;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTThumbsDataSource : TTTableViewDataSource {
  id<TTThumbsTableViewCellDelegate> _delegate;
  id<TTPhotoSource> _photoSource;
}

@property(nonatomic,assign) id<TTThumbsTableViewCellDelegate> delegate;
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource
      delegate:(id<TTThumbsTableViewCellDelegate>)delegate;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTThumbsViewControllerDelegate <NSObject>

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo;

@optional

- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
        shouldNavigateToPhoto:(id<TTPhoto>)photo;

@end
