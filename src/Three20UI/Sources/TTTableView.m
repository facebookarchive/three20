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

#import "Three20UI/TTTableView.h"

// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTStyledTextLabel.h"
#import "Three20UI/UIViewAdditions.h"

// UICommon
#import "Three20UICommon/UIWindowAdditions.h"

// Style
#import "Three20Style/TTStyledNode.h"
#import "Three20Style/TTStyledButtonNode.h"
#import "Three20Style/TTStyledLinkNode.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kShadowHeight        = 20.0;
static const CGFloat kShadowInverseHeight = 10.0;

static const CGFloat kCancelHighlightThreshold = 4;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableView

@synthesize highlightedLabel  = _highlightedLabel;
@synthesize contentOrigin     = _contentOrigin;
@synthesize showShadows       = _showShadows;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:style];
  if (self) {
    _highlightStartPoint = CGPointZero;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_highlightedLabel);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesBegan:touches withEvent:event];

  if ([self.delegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)]) {
    id<TTTableViewDelegate> delegate = (id<TTTableViewDelegate>)self.delegate;
    [delegate tableView:self touchesBegan:touches withEvent:event];
  }

  if (_highlightedLabel) {
    UITouch* touch = [touches anyObject];
    _highlightStartPoint = [touch locationInView:self];
  }

//  if (_menuView) {
//    UITouch* touch = [touches anyObject];
//    CGPoint point = [touch locationInView:_menuView];
//    if (point.y < 0 || point.y > _menuView.height) {
//      [self hideMenu:YES];

//    } else {
//      UIView* hit = [_menuView hitTest:point withEvent:event];
//      if (![hit isKindOfClass:[UIControl class]]) {
//        [self hideMenu:YES];
//      }
//    }
//  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    if ([self.delegate respondsToSelector:@selector(tableView:touchesMoved:withEvent:)]) {
        id<TTTableViewDelegate> delegate = (id<TTTableViewDelegate>)self.delegate;
        [delegate tableView:self touchesMoved:touches withEvent:event];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesEnded:touches withEvent:event];

  if ([self.delegate respondsToSelector:@selector(tableView:touchesEnded:withEvent:)]) {
    id<TTTableViewDelegate> delegate = (id<TTTableViewDelegate>)self.delegate;
    [delegate tableView:self touchesEnded:touches withEvent:event];
  }

  if (_highlightedLabel) {
    TTStyledElement* element = _highlightedLabel.highlightedNode;
    // This is a dirty hack to decouple the UI from Style. TTOpenURL was originally within
    // the node implementation. One potential fix would be to provide some protocol for these
    // nodes to converse with.
    if ([element isKindOfClass:[TTStyledLinkNode class]]) {
      TTOpenURLFromView([(TTStyledLinkNode*)element URL], self);

    } else if ([element isKindOfClass:[TTStyledButtonNode class]]) {
      TTOpenURLFromView([(TTStyledButtonNode*)element URL], self);


    } else {
      [element performDefaultAction];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentSize:(CGSize)size {
  if (_contentOrigin) {
    CGFloat minHeight = self.height + _contentOrigin;
    if (size.height < minHeight) {
      size.height = self.height + _contentOrigin;
    }
  }

  CGFloat y = self.contentOffset.y;
  [super setContentSize:size];

  if (_contentOrigin) {
    // As described below in setContentOffset, UITableView insists on messing with the
    // content offset sometimes when you change the content size or the height of the table
    self.contentOffset = CGPointMake(0, y);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentOffset:(CGPoint)point {
  // UITableView (and UIScrollView) are really stupid about resetting the content offset
  // when the table view itself is resized.  There are times when I scroll to a point and then
  // disable scrolling, and I don't want the table view scrolling somewhere else just because
  // it was resized.
  if (self.scrollEnabled) {
    if (!(_contentOrigin && self.contentOffset.y == _contentOrigin && point.y == 0)) {
      [super setContentOffset:point];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
  // -[UITableView reloadData] takes away first responder status if the first responder is a
  // subview, so remember it and then restore it afterward to avoid awkward keyboard disappearance
  UIResponder* firstResponder = [self.window findFirstResponderInView:self];

  CGFloat y = self.contentOffset.y;
  [super reloadData];

  if (nil != firstResponder) {
    [firstResponder becomeFirstResponder];
  }

  if (_highlightedLabel) {
    self.highlightedLabel = nil;
  }

  if (_contentOrigin) {
    self.contentOffset = CGPointMake(0, y);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
        scrollPosition:(UITableViewScrollPosition)scrollPosition {
  if (!_highlightedLabel) {
    [super selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CAGradientLayer*)shadowAsInverse:(BOOL)inverse {
  CAGradientLayer* newShadow = [[[CAGradientLayer alloc] init] autorelease];
  CGRect newShadowFrame = CGRectMake(0.0, 0.0,
                                     self.frame.size.width,
                                     inverse ? kShadowInverseHeight : kShadowHeight);
  newShadow.frame = newShadowFrame;

  CGColorRef darkColor = [UIColor colorWithRed:0.0
                                         green:0.0
                                          blue:0.0
                                         alpha:inverse ?
                                               (kShadowInverseHeight / kShadowHeight) * 0.5
                                               : 0.5].CGColor;
  CGColorRef lightColor = [self.backgroundColor
                           colorWithAlphaComponent:0.0].CGColor;

  newShadow.colors = [NSArray arrayWithObjects:
            (id)(inverse ? lightColor : darkColor),
            (id)(inverse ? darkColor : lightColor),
            nil];
  return newShadow;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  if (!_showShadows || UITableViewStylePlain != self.style) {
    return;
  }

  // Initialize the shadow layers.
  if (nil == _originShadow) {
    _originShadow = [self shadowAsInverse:NO];
    [self.layer insertSublayer:_originShadow atIndex:0];

  } else if (![[self.layer.sublayers objectAtIndex:0] isEqual:_originShadow]) {
    [_originShadow removeFromSuperlayer];
    [self.layer insertSublayer:_originShadow atIndex:0];
  }

  [CATransaction begin];
  [CATransaction setValue: (id)kCFBooleanTrue
                   forKey: kCATransactionDisableActions];

  CGRect originShadowFrame = _originShadow.frame;
  originShadowFrame.size.width = self.frame.size.width;
  originShadowFrame.origin.y = self.contentOffset.y;
  _originShadow.frame = originShadowFrame;

  [CATransaction commit];

  // Remove the table cell shadows if there aren't any cells.
  NSArray* indexPathsForVisibleRows = [self indexPathsForVisibleRows];
  if (0 == [indexPathsForVisibleRows count]) {
    [_topShadow removeFromSuperlayer];
    TT_RELEASE_SAFELY(_topShadow);

    [_bottomShadow removeFromSuperlayer];
    TT_RELEASE_SAFELY(_bottomShadow);
    return;
  }

  // Assumptions at this point: There are cells.
  NSIndexPath* firstRow = [indexPathsForVisibleRows objectAtIndex:0];

  // Check whether or not the very first row is visible.
  if (0 == [firstRow section]
      && 0 == [firstRow row]) {
    UIView* cell = [self cellForRowAtIndexPath:firstRow];

    // Create the top shadow if necessary.
    if (nil == _topShadow) {
      _topShadow = [[self shadowAsInverse:YES] retain];
      [cell.layer insertSublayer:_topShadow atIndex:0];

    }  else if ([cell.layer.sublayers indexOfObjectIdenticalTo:_topShadow] != 0) {
      [_topShadow removeFromSuperlayer];
      [cell.layer insertSublayer:_topShadow atIndex:0];
    }

    CGRect shadowFrame = _topShadow.frame;
    shadowFrame.size.width = cell.frame.size.width;
    shadowFrame.origin.y = -kShadowInverseHeight;
    _topShadow.frame = shadowFrame;

  } else {
    [_topShadow removeFromSuperlayer];
    TT_RELEASE_SAFELY(_topShadow);
  }

  NSIndexPath* lastRow = [indexPathsForVisibleRows lastObject];

  // Check whether or not the very last row is visible.
  if ([lastRow section] == [self numberOfSections] - 1
      && [lastRow row] == [self numberOfRowsInSection:[lastRow section]] - 1) {
    UIView* cell = [self cellForRowAtIndexPath:lastRow];

    if (nil == _bottomShadow) {
      _bottomShadow = [[self shadowAsInverse:NO] retain];
      [cell.layer insertSublayer:_bottomShadow atIndex:0];

    }  else if ([cell.layer.sublayers indexOfObjectIdenticalTo:_bottomShadow] != 0) {
      [_bottomShadow removeFromSuperlayer];
      [cell.layer insertSublayer:_bottomShadow atIndex:0];
    }

    CGRect shadowFrame = _bottomShadow.frame;
    shadowFrame.size.width = cell.frame.size.width;
    shadowFrame.origin.y = cell.frame.size.height;
    _bottomShadow.frame = shadowFrame;

  } else {
    [_bottomShadow removeFromSuperlayer];
    TT_RELEASE_SAFELY(_bottomShadow);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedLabel:(TTStyledTextLabel*)label {
  if (label != _highlightedLabel) {
    _highlightedLabel.highlightedNode = nil;
    [_highlightedLabel release];
    _highlightedLabel = [label retain];
  }
}


@end
