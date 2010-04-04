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

#import "Three20/TTPopupViewController.h"

#import "Three20/TTGlobalUI.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPopupViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundle {
	if (self = [super initWithNibName:nibName bundle:bundle]) {
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	}

	return self;
}

- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}

- (void)dealloc {
  self.superController.popupViewController = nil;
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)showInView:(UIView*)view animated:(BOOL)animated {
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
}

- (BOOL)canBeTopViewController {
  return NO;
}

@end
