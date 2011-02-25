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

#import "Three20UINavigator/TTURLAction.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLAction

@synthesize urlPath       = _urlPath;
@synthesize parentURLPath = _parentURLPath;
@synthesize query         = _query;
@synthesize state         = _state;
@synthesize animated      = _animated;
@synthesize withDelay     = _withDelay;
@synthesize sourceRect    = _sourceRect;
@synthesize sourceView    = _sourceView;
@synthesize sourceButton  = _sourceButton;
@synthesize passthroughViews = _passthroughViews;
@synthesize transition    = _transition;
@synthesize targetPopoverController = _targetPopoverController;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURLPath:(NSString*)urlPath {
  if (self = [super init]) {
    self.urlPath = urlPath;
    self.transition = UIViewAnimationTransitionNone;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithURLPath:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_urlPath);
  TT_RELEASE_SAFELY(_parentURLPath);
  TT_RELEASE_SAFELY(_query);
  TT_RELEASE_SAFELY(_state);
  TT_RELEASE_SAFELY(_sourceView);
  TT_RELEASE_SAFELY(_sourceButton);
  TT_RELEASE_SAFELY(_passthroughViews);
  TT_RELEASE_SAFELY(_targetPopoverController);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [NSString stringWithFormat:
          @"<TTURLAction: %p"
          @"; urlPath = %@"
          @"; parentUrlPath = %@"
          @"; query = %@"
          @"; state = %@"
          @"; animated = %d"
          @"; withDelay = %d"
          @"; sourceRect = %@"
          @"; sourceView = %@"
          @"; sourceButton = %@"
          @"; passthroughViews = %@"
          @"; transition = %d"   // TODO (jverkoey Jan 25, 2011): Make a utility method for this.
          @">",
          self,
          self.urlPath,
          self.parentURLPath,
          self.query,
          self.state,
          self.animated,
          self.withDelay,
          NSStringFromCGRect(self.sourceRect),
          self.sourceView,
          self.sourceButton,
          self.passthroughViews,
          self.transition];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)action {
  return [[[self alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)actionWithURLPath:(NSString*)urlPath {
  return [[[self alloc] initWithURLPath:urlPath] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyParentURLPath:(NSString*)parentURLPath {
  self.parentURLPath = parentURLPath;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyQuery:(NSDictionary*)query {
  self.query = query;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyState:(NSDictionary*)state {
  self.state = state;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyAnimated:(BOOL)animated {
  self.animated = animated;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyWithDelay:(BOOL)withDelay {
  self.withDelay = withDelay;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applySourceRect:(CGRect)sourceRect {
  self.sourceRect = sourceRect;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applySourceView:(UIView*)sourceView {
  self.sourceView = sourceView;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applySourceButton:(UIBarButtonItem*)sourceButton {
  self.sourceButton = sourceButton;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyPassthroughViews:(NSArray*)passthroughViews {
  self.passthroughViews = passthroughViews;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyTargetPopoverController:(UIPopoverController*)targetPopoverController {
  self.targetPopoverController = targetPopoverController;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTURLAction*)applyTransition:(UIViewAnimationTransition)transition {
  self.transition = transition;
  return self;
}


@end
