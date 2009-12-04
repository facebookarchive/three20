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

#import "Three20/TTGlobal.h"

@class TTURLRequest;

@protocol TTURLResponse <NSObject>

/**
 * Processes the data from a successful request and determines if it is valid.
 *
 * If the data is not valid, return an error.  The data will not be cached if there is an error.
 */
- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data;

@end

@interface TTURLDataResponse : NSObject <TTURLResponse> {
  NSData* _data;
}

@property(nonatomic,readonly) NSData* data;

@end

@interface TTURLImageResponse : NSObject <TTURLResponse> {
  UIImage* _image;
}

@property(nonatomic,readonly) UIImage* image;

@end
