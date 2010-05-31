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

#import "extThree20CSSStyle/TTCSSParser.h"

#import "extThree20CSSStyle/private/CssTokens.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"


typedef enum {
  None,

} ParserStates;


// Damn you, flex. Due to the nature of the global methods and whatnot, we can only have one
// parser at any given time.
TTCSSParser* gActiveParser = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TTCSSParser()

- (void)consumeToken:(int)token text:(char*)text;

@end



///////////////////////////////////////////////////////////////////////////////////////////////////
int cssConsume(char* text, int token) {
  [gActiveParser consumeToken:token text:text];

  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTCSSParser


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _definitions = [[NSMutableDictionary alloc] init];
    _activeNames = [[NSMutableArray alloc] init];
    _activeProperties = [[NSMutableDictionary alloc] init];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_definitions);
  TT_RELEASE_SAFELY(_activeNames);
  TT_RELEASE_SAFELY(_activeProperties);
  TT_RELEASE_SAFELY(_activePropertyName);
  TT_RELEASE_SAFELY(_lastTokenText);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)consumeToken:(int)token text:(char*)text {
  NSString* string = [NSString stringWithCString: text
                                        encoding: NSUTF8StringEncoding];
  switch (token) {
    case CSSHASH:
    case CSSIDENT: {
      if (_state.Flags.InsideDefinition) {
        TT_RELEASE_SAFELY(_activePropertyName);
        _activePropertyName = [string retain];

        NSMutableArray* values = [[NSMutableArray alloc] init];
        [_activeProperties setObject:values forKey:_activePropertyName];
        TT_RELEASE_SAFELY(values);

      } else {
        if (_lastToken == CSSUNKNOWN && [_lastTokenText isEqualToString:@"."]) {
          string = [_lastTokenText stringByAppendingString:string];
        }
        [_activeNames addObject:string];
        TT_RELEASE_SAFELY(_activePropertyName);
      }
      break;
    }

    case CSSEMS:
    case CSSEXS:
    case CSSLENGTH:
    case CSSANGLE:
    case CSSTIME:
    case CSSFREQ:
    case CSSDIMEN:
    case CSSPERCENTAGE:
    case CSSNUMBER:
    case CSSURI: {
      TTDASSERT(nil != _activePropertyName);

      if (nil != _activePropertyName) {
        NSMutableArray* values = [_activeProperties objectForKey:_activePropertyName];
        [values addObject:string];
      }
      break;
    }

    case CSSUNKNOWN: {
      switch (text[0]) {
        case '{': {
          _state.Flags.InsideDefinition = YES;
          break;
        }

        case '}': {
          for (NSString* name in _activeNames) {
            NSMutableDictionary* existingProperties = [_definitions objectForKey:name];
            if (nil != existingProperties) {
              // Overwrite the properties, instead!

              NSDictionary* iteratorProperties = [_activeProperties copy];
              for (NSString* key in iteratorProperties) {
                [existingProperties setObject:[_activeProperties objectForKey:key] forKey:key];
              }
              TT_RELEASE_SAFELY(iteratorProperties);

            } else {
              [_definitions setObject:_activeProperties forKey:name];
            }
          }
          [_activeNames removeAllObjects];
          _state.Flags.InsideDefinition = NO;
          break;
        }
      }
      break;
    }
  }

  [_lastTokenText release];
  _lastTokenText = [string retain];
  _lastToken = token;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)parseFilename:(NSString*)filename {
  gActiveParser = self;

  [_definitions removeAllObjects];
  [_activeNames removeAllObjects];
  [_activeProperties removeAllObjects];
  TT_RELEASE_SAFELY(_activePropertyName);
  TT_RELEASE_SAFELY(_lastTokenText);

  cssin = fopen([filename UTF8String], "r");

  csslex();

  fclose(cssin);

  NSDictionary* result = [[_definitions copy] autorelease];
  TT_RELEASE_SAFELY(_definitions);
  return result;
}


@end

