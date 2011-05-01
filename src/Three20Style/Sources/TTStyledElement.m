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

#import "Three20Style/TTStyledElement.h"

// Style
#import "Three20Style/TTStyledTextNode.h"

// Style (private)
#import "Three20Style/private/TTStyledNodeInternal.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledElement

@synthesize firstChild  = _firstChild;
@synthesize lastChild   = _lastChild;
@synthesize className   = _className;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithText:(NSString*)text {
  if (self = [self initWithText:text next:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithText:(NSString*)text next:(TTStyledNode*)nextSibling {
  if (self = [super initWithNextSibling:nextSibling]) {
    if (nil != text) {
      [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithText:nil next:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_firstChild);
  TT_RELEASE_SAFELY(_className);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [NSString stringWithFormat:@"%@", _firstChild];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyledNode


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)outerText {
  if (_firstChild) {
    NSMutableArray* strings = [NSMutableArray array];
    for (TTStyledNode* node = _firstChild; node; node = node.nextSibling) {
      [strings addObject:node.outerText];
    }
    return [strings componentsJoinedByString:@""];

  } else {
    return [super outerText];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)outerHTML {
  NSString* html = nil;
  if (_firstChild) {
    html = [NSString stringWithFormat:@"<div>%@</div>", _firstChild.outerHTML];

  } else {
    html = @"<div/>";
  }
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", html, _nextSibling.outerHTML];

  } else {
    return html;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addChild:(TTStyledNode*)child {
  if (!_firstChild) {
    _firstChild = [child retain];
    _lastChild = [self findLastSibling:child];

  } else {
    _lastChild.nextSibling = child;
    _lastChild = [self findLastSibling:child];
  }
  child.parentNode = self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addText:(NSString*)text {
  [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)replaceChild:(TTStyledNode*)oldChild withChild:(TTStyledNode*)newChild {
  if (oldChild == _firstChild) {
    newChild.nextSibling = oldChild.nextSibling;
    oldChild.nextSibling = nil;
    newChild.parentNode = self;
    if (oldChild == _lastChild) {
      _lastChild = newChild;
    }
    [_firstChild release];
    _firstChild = [newChild retain];

  } else {
    TTStyledNode* node = _firstChild;
    while (node) {
      if (node.nextSibling == oldChild) {
        [oldChild retain];
        if (newChild) {
          newChild.nextSibling = oldChild.nextSibling;
          node.nextSibling = newChild;

        } else {
          node.nextSibling = oldChild.nextSibling;
        }
        oldChild.nextSibling = nil;
        newChild.parentNode = self;
        if (oldChild == _lastChild) {
          _lastChild = newChild ? newChild : node;
        }
        [oldChild release];
        break;
      }
      node = node.nextSibling;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledNode*)getElementByClassName:(NSString*)className {
  TTStyledNode* node = _firstChild;
  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* element = (TTStyledElement*)node;
      if ([element.className isEqualToString:className]) {
        return element;
      }

      TTStyledNode* found = [element getElementByClassName:className];
      if (found) {
        return found;
      }
    }
    node = node.nextSibling;
  }
  return nil;
}


@end
