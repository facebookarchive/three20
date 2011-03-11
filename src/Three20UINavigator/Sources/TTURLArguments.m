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

#import "Three20UINavigator/private/TTURLArguments.h"

#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
TTURLArgumentType TTConvertArgumentType(char argType) {
  if (argType == 'c'
      || argType == 'i'
      || argType == 's'
      || argType == 'l'
      || argType == 'C'
      || argType == 'I'
      || argType == 'S'
      || argType == 'L') {
    return TTURLArgumentTypeInteger;

  } else if (argType == 'q' || argType == 'Q') {
    return TTURLArgumentTypeLongLong;

  } else if (argType == 'f') {
    return TTURLArgumentTypeFloat;

  } else if (argType == 'd') {
    return TTURLArgumentTypeDouble;

  } else if (argType == 'B') {
    return TTURLArgumentTypeBool;

  } else {
    return TTURLArgumentTypePointer;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
TTURLArgumentType TTURLArgumentTypeForProperty(Class cls, NSString* propertyName) {
  objc_property_t prop = class_getProperty(cls, propertyName.UTF8String);
  if (prop) {
    const char* type = property_getAttributes(prop);
    return TTConvertArgumentType(type[1]);

  } else {
    return TTURLArgumentTypeNone;
  }
}
