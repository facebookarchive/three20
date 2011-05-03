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

typedef enum {
  TTNavigationModeNone,
  TTNavigationModeCreate,            // a new view controller is created each time
  TTNavigationModeShare,             // a new view controller is created, cached and re-used
  TTNavigationModeModal,             // a new view controller is created and presented modally
  TTNavigationModePopover,           // a new view controller is created and presented in a popover
  TTNavigationModeExternal,          // an external app will be opened
} TTNavigationMode;
