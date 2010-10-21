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

@protocol TTLauncherItemDelegate;

/**
 * A simple data object for the launcher view.
 *
 * Defines the basic components used to create a TTLauncherButton.
 */
@interface TTLauncherItem : NSObject <NSCoding> {
  NSString*       _title;
  NSString*       _image;
  NSString*       _URL;

  NSString*       _style;
  NSInteger       _badgeNumber;

  BOOL            _canDelete;

  id<TTLauncherItemDelegate> _delegate;
}

// Designated initializer.
- (id)initWithTitle: (NSString*)title
              image: (NSString*)image
                URL: (NSString*)URL
          canDelete: (BOOL)canDelete;

- (id)initWithTitle: (NSString*)title
              image: (NSString*)image
                URL: (NSString*)URL;


/**
 * The text shown directly below the icon.
 */
@property (nonatomic, copy)   NSString*       title;

/**
 * A URLPath to the image.
 *
 * TODO(jverkoey, Oct 21, 2010): This should be imageURLPath.
 */
@property (nonatomic, copy)   NSString*       image;

/**
 * The URLPath to execute when this item is tapped.
 *
 * TODO(jverkoey, Oct 21, 2010): This should be urlPath.
 */
@property (nonatomic, copy)   NSString*       URL;

/**
 * The TTStyle to use for the TTLauncherButton.
 *
 * @default If none is set, TTLauncherButton uses @"launcherButton:".
 */
@property (nonatomic, copy)   NSString*       style;

/**
 * The number shown in a badge in the corner of the button.
 *
 * Max value: 99
 */
@property (nonatomic)         NSInteger       badgeNumber;

/**
 * Whether or not to show the delete button in editing mode.
 *
 * TODO(jverkoey, Oct 21, 2010): This should be canShowDeleteButton.
 */
@property (nonatomic)         BOOL            canDelete;

@property (nonatomic, assign) id<TTLauncherItemDelegate> delegate;


@end
