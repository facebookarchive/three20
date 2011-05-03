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

#import "Three20UI/TTRecursiveProgress.h"

// Core
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTRecursiveProgress

@synthesize firstPercent  = _firstPercent;
@synthesize lastPercent   = _lastPercent;
@synthesize delegate      = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)progressWithDelegate:(id<TTRecursiveProgressDelegate>)delegate {
  return [[[self alloc] initWithDelegate:delegate] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)progressWithParent: (TTRecursiveProgress*)parent
            firstPercent: (CGFloat)firstPercent
             lastPercent: (CGFloat)lastPercent {
  return [[[self alloc] initWithParent: parent
                          firstPercent: firstPercent
                           lastPercent: lastPercent] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<TTRecursiveProgressDelegate>)delegate {
  if (self = [super init]) {
    _firstPercent = 0;
    _lastPercent = 1;
    _parent = nil;
    self.delegate = delegate;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithParent:(TTRecursiveProgress*)parent
        firstPercent: (CGFloat)firstPercent
         lastPercent: (CGFloat)lastPercent {
  if (self = [super init]) {
    _firstPercent = firstPercent;
    _lastPercent = lastPercent;
    _parent = parent;
    _delegate = nil;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)percentWidth {
  return _lastPercent - _firstPercent;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPercent:(CGFloat)percent {
  CGFloat mappedProgress = [self percentWidth] * percent + _firstPercent;
  if (nil == _parent) {
    [_delegate didSetProgress:mappedProgress];

  } else {
    [_parent setPercent:mappedProgress];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)percent {
  // You can't request progress from this object.
  TTDASSERT(NO);
  return 0;
}

@end

