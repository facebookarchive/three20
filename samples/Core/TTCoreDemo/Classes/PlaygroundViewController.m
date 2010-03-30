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

#import "PlaygroundViewController.h"

static const CGFloat kFramePadding = 10;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation PlaygroundViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadView {
  [super loadView];

  UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setTitle:NSLocalizedString(@"Debug test", @"") forState:UIControlStateNormal];
  [button addTarget: self
             action: @selector(debugTestAction)
   forControlEvents: UIControlEventTouchUpInside];
  [button sizeToFit];

  CGRect frame = button.frame;
  frame.origin.x = kFramePadding;
  frame.origin.y = kFramePadding;
  button.frame = frame;

  [self.view addSubview:button];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) debugTestAction {
  NSLog(@"Three20 debugging is currently...%@", ((DEBUG) ? @"ON" : @"OFF"));

  // This will print the current method name.
  TTDPRINTMETHODNAME();

  TTDPRINT(@"Showing TTDPRINT.");
  TTDPRINT(@"-----------------");
  TTDPRINT(@"Showing TTD log levels <= %d", TTMAXLOGLEVEL);
  TTDERROR(@"This is TTDERROR, level %d.", TTLOGLEVEL_ERROR);
  TTDWARNING(@"This is TTDWARNING, level %d.", TTLOGLEVEL_WARNING);
  TTDINFO(@"This is TTDINFO, level %d.", TTLOGLEVEL_INFO);

  TTDPRINT(@"");
  TTDPRINT(@"Showing TTDCONDITIONLOG.");
  TTDPRINT(@"------------------------");
  TTDCONDITIONLOG(true, @"This will always display, because the condition is \"true\"");
  TTDCONDITIONLOG(false, @"This will never display, because the condition is \"false\"");
  TTDCONDITIONLOG(rand()%2, @"This will randomly display, because the condition is \"rand()%2\"");

  TTDPRINT(@"");
  TTDPRINT(@"Showing TTDASSERT.");
  TTDPRINT(@"------------------");
  // Should do nothing at all.
  TTDASSERT(true);

  // This will jump you into the debugger in the simulator.
  // Note that this isn't a crash! Simply the equivalent of setting
  // a breakpoint in the debugger, but programmatically. These TTDASSERTs
  // will be completely stripped away from your final product, assuming
  // you don't declare the DEBUG preprocessor macro (and you shouldn't
  // be).
  TTDASSERT(false);
}


@end
