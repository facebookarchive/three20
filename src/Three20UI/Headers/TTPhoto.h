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

// UI
#import "Three20UI/TTPhotoVersion.h"

// UINavigator
#import "Three20UINavigator/TTURLObject.h"

@protocol TTPhotoSource;

@protocol TTPhoto <NSObject, TTURLObject>

/**
 * The photo source that the photo belongs to.
 */
@property (nonatomic, assign) id<TTPhotoSource> photoSource;

/**
 * The size of the photo.
 */
@property (nonatomic) CGSize size;

/**
 * The index of the photo within its photo source.
 */
@property (nonatomic) NSInteger index;

/**
 * The caption of the photo.
 */
@property (nonatomic, copy) NSString* caption;

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(TTPhotoVersion)version;

@end
