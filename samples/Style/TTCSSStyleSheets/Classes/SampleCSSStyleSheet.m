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

#import "SampleCSSStyleSheet.h"

@implementation SampleCSSStyleSheet

- (TTStyle *)h3:(UIControlState)state {
  return
  [TTSolidFillStyle styleWithColor:TTCSSSTATE(@"h3", backgroundColor, state) next:
   [TTTextStyle styleWithCssSelector:@"h3" forState:state next:
    nil]];
}

- (TTStyle *)h4:(UIControlState)state {
  return
  [TTSolidFillStyle styleWithColor:TTCSSSTATE(@"h4text", backgroundColor, state) next:
   [TTShadowStyle styleWithCssSelector:@"h4shadow" forState:state next:
    [TTTextStyle styleWithCssSelector:@"h4text" forState:state next:
     nil]]];
}

@end
