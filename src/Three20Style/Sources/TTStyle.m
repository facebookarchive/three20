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

#import "Three20Style/TTStyle.h"

// Style
#import "Three20Style/TTPartStyle.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


#define ZEROLIMIT(_VALUE) (_VALUE < 0 ? 0 : (_VALUE > 1 ? 1 : _VALUE))


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyle

@synthesize next = _next;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(TTStyle*)next {
	self = [super init];
  if (self) {
    _next = [next retain];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [self initWithNext:nil];
  if (self) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_next);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)next:(TTStyle*)next {
  self.next = next;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(TTStyleContext*)context {
  [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
  if (self.next) {
    return [self.next addToInsets:insets forSize:size];

  } else {
    return insets;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(TTStyleContext*)context {
  if (_next) {
    return [self.next addToSize:size context:context];

  } else {
    return size;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addStyle:(TTStyle*)style {
  if (_next) {
    [_next addStyle:style];

  } else {
    _next = [style retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)firstStyleOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;

  } else {
    return [self.next firstStyleOfClass:cls];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)styleForPart:(NSString*)name {
  TTStyle* style = self;
  while (style) {
    if ([style isKindOfClass:[TTPartStyle class]]) {
      TTPartStyle* partStyle = (TTPartStyle*)style;
      if ([partStyle.name isEqualToString:name]) {
        return partStyle;
      }
    }
    style = style.next;
  }
  return nil;
}


@end
