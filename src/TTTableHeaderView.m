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

#import "Three20/TTTableHeaderView.h"

#import "Three20/TTGlobalUI.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableHeaderView

- (id)initWithTitle:(NSString*)title {
  if (self = [super init]) {
    self.backgroundColor = [UIColor clearColor];
    self.style = TTSTYLE(tableHeader);
    
    _label = [[UILabel alloc] init];
    _label.text = title;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = TTSTYLEVAR(tableHeaderTextColor)
                       ? TTSTYLEVAR(tableHeaderTextColor)
                       : TTSTYLEVAR(linkTextColor);
    _label.shadowColor = TTSTYLEVAR(tableHeaderShadowColor)
                         ? TTSTYLEVAR(tableHeaderShadowColor)
                         : [UIColor clearColor];
    _label.shadowOffset = CGSizeMake(0, 1);
    _label.font = TTSTYLEVAR(tableHeaderPlainFont);
    [self addSubview:_label];
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_label);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  _label.frame = CGRectMake(12, 0, self.width, self.height);
}

@end

