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

#import "Three20/TTURLMap.h"
#import "Three20/TTModel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#define TT_NULL_PHOTO_INDEX NSIntegerMax

@protocol TTPhoto;
@class TTURLRequest;

typedef enum {
  TTPhotoVersionNone,
  TTPhotoVersionLarge,
  TTPhotoVersionMedium,
  TTPhotoVersionSmall,
  TTPhotoVersionThumbnail
} TTPhotoVersion;

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPhotoSource <TTModel, TTURLObject>

/**
 * The title of this collection of photos.
 */
@property(nonatomic,copy) NSString* title;

/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
@property(nonatomic,readonly) NSInteger numberOfPhotos;

/**
 * The maximum index of photos that have already been loaded.
 */
@property(nonatomic,readonly) NSInteger maxPhotoIndex;

/**
 *
 */
- (id<TTPhoto>)photoAtIndex:(NSInteger)index;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPhoto <NSObject, TTURLObject>

/**
 * The photo source that the photo belongs to.
 */
@property(nonatomic,assign) id<TTPhotoSource> photoSource;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) CGSize size;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) NSInteger index;

/**
 * The caption of the photo.
 */
@property(nonatomic,copy) NSString* caption;

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(TTPhotoVersion)version;

@end
