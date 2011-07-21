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

#import "Three20UI/TTScrollView.h"

// UI
#import "Three20UI/TTScrollViewDelegate.h"
#import "Three20UI/TTScrollViewDataSource.h"
#import "Three20UI/UIViewAdditions.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const NSInteger kOffscreenPages = 1;
static const CGFloat kDefaultPageSpacing = 40.0;
static const CGFloat kFlickThreshold = 60.0;
static const CGFloat kTapZoom = 0.75;
static const CGFloat kResistance = 0.15;
static const NSInteger kInvalidIndex = -1;
static const NSTimeInterval kFlickDuration = 0.4;
static const NSTimeInterval kBounceDuration = 0.3;
static const NSTimeInterval kOvershoot = 2;
static const CGFloat kIncreaseSpeed = 1.5;    // How much increase after release touch.
                                              // (Residual movement).
static const CGFloat kFrameDuration = 1.0/40.0;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTScrollView

@synthesize delegate        = _delegate;
@synthesize dataSource      = _dataSource;
@synthesize centerPageIndex = _centerPageIndex;
@synthesize pageSpacing     = _pageSpacing;
@synthesize scrollEnabled   = _scrollEnabled;
@synthesize zoomEnabled     = _zoomEnabled;
@synthesize rotateEnabled   = _rotateEnabled;
@synthesize orientation     = _orientation;
@synthesize holding         = _holding;

@synthesize holdsAfterTouchingForInterval = _holdsAfterTouchingForInterval;

@synthesize decelerationRate = _decelerationRate;
@synthesize decelerating     = _decelerating;

@synthesize maximumZoomScale  = _maximumZoomScale;
@synthesize zoomScale         = _zoomScale;
@synthesize zooming           = _executingZoomGesture;

@synthesize isDragging        = _dragging;

@synthesize centerPageAnimationDuration = _centerPageAnimationDuration;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
  if (self) {
    self.clipsToBounds = YES;
    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;

    _maxPages = (kOffscreenPages*2) + 1;
    _pages = [[NSMutableArray alloc] initWithCapacity:_maxPages];
    _pageQueue = [[NSMutableArray alloc] init];
    _pageSpacing = kDefaultPageSpacing;
    _visiblePageIndex = kInvalidIndex;
    _scrollEnabled = YES;
    _zoomEnabled = YES;
    _rotateEnabled = YES;
    _orientation = UIDeviceOrientationPortrait;
    _decelerationRate = 0.9;      // Inertia, how faster slow the residual movement.
    _maximumZoomScale = 4.0;      // Maximum zoom scale default value.
    _centerPageAnimationDuration = TT_TRANSITION_DURATION;

    for (NSInteger i = 0; i < _maxPages; ++i) {
      [_pages addObject:[NSNull null]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(deviceOrientationDidChange:)
      name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIDeviceOrientationDidChangeNotification" object:nil];

  _delegate = nil;
  [_animationTimer invalidate];
  [_tapTimer invalidate];
  TT_RELEASE_SAFELY(_animationStartTime);
  TT_RELEASE_SAFELY(_pages);
  TT_RELEASE_SAFELY(_pageQueue);

  TT_RELEASE_SAFELY(_touch1);
  TT_RELEASE_SAFELY(_touch2);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFirstPage {
  return _centerPageIndex == 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLastPage {
  return _centerPageIndex + 1 >= [_dataSource numberOfPagesInScrollView:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)draggingFromEdge {
  return (_pageEdges.left < 0 && [self isLastPage])
      || (_pageEdges.left > 0 && [self isFirstPage]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)flipped {
  return _orientation == UIInterfaceOrientationLandscapeLeft
      || _orientation == UIInterfaceOrientationPortraitUpsideDown;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)pinched {
  return -_pageEdges.left + _pageEdges.right < 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)pulled {
  return _pageEdges.left > 0 || _pageEdges.top > 0
      || _pageEdges.right < 0 || _pageEdges.bottom < 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)flicked {
  if (!self.flipped) {
    if (_pageEdges.left > kFlickThreshold && ![self isFirstPage]) {
      return YES;

    } else if (_pageEdges.right < -kFlickThreshold && ![self isLastPage]) {
      return YES;

    } else {
      return NO;
    }

  } else {
    if (_pageEdges.left > kFlickThreshold && ![self isLastPage]) {
      return YES;

    } else if (_pageEdges.right < -kFlickThreshold && ![self isFirstPage]) {
      return YES;

    } else {
      return NO;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)pageWidth {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return self.height;

  } else {
    return self.width;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)pageHeight {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return self.width;

  } else {
    return self.height;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)overshoot {
  return _pageEdges.left < 0 ? -_overshoot : _overshoot;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)stretchedWidth {
  return -_pageEdges.left + self.pageWidth + _pageEdges.right;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)stretchedHeight {
  return -_pageEdges.top + self.pageHeight + _pageEdges.bottom;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)zoomFactor {
  return self.stretchedWidth / self.pageWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameOfPageAtIndex:(NSInteger)pageIndex {
  CGSize size;
  if ([_dataSource respondsToSelector:@selector(scrollView:sizeOfPageAtIndex:)]) {
    size = [_dataSource scrollView:self sizeOfPageAtIndex:pageIndex];
    if (0 == size.width || 0 == size.height) {
      size = CGSizeMake(self.pageWidth, self.pageHeight);
    }

  } else {
    size = CGSizeMake(self.pageWidth, self.pageHeight);
  }

  CGFloat width, height;
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    if (size.width / size.height > self.width / self.height) {
      height = self.height;
      width = size.height/size.width * self.height;

    } else {
      height = size.width/size.height * self.width;
      width = self.width;
    }

  } else {
    if (size.width / size.height > self.width / self.height) {
      width = self.width;
      height = size.height/size.width * self.width;

    } else {
      width = size.width/size.height * self.height;
      height = self.height;
    }
  }

  CGFloat xd = width - self.width;
  CGFloat yd = height - self.height;
  return CGRectMake(-xd/2, -yd/2, width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)overflowForFrame:(CGRect)frame {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return frame.origin.y < 0 ? fabs(frame.origin.y) : 0;

  } else {
    return frame.origin.x < 0 ? fabs(frame.origin.x) : 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)offsetForOrientation:(CGFloat)x y:(CGFloat)y {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return CGPointMake(y, x);

  } else {
    return CGPointMake(x, y);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)supportsOrientation:(UIInterfaceOrientation)orientation {
  return orientation == UIInterfaceOrientationLandscapeLeft
  || orientation == UIInterfaceOrientationLandscapeRight
  || orientation == UIInterfaceOrientationPortrait
  || orientation == UIInterfaceOrientationPortraitUpsideDown
  || orientation == UIDeviceOrientationFaceDown
  || orientation == UIDeviceOrientationFaceUp;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * TODO: Candidate for a more general purpose location. Pull the orientation into the method
 * params and expose this method as a static method.
 */
- (CGAffineTransform)rotateTransform:(CGAffineTransform)transform {
  if (_orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformRotate(transform, M_PI*1.5);

  } else if (_orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformRotate(transform, M_PI/2);

  } else if (_orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformRotate(transform, -M_PI);

  } else {
    return transform;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Get the location of the touch by taking into account the orientation.
 * In landscape mode, the x and y values are flipped.
 */
- (CGPoint)touchLocation:(UITouch*)touch {
  CGPoint point = [touch locationInView:self];
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return CGPointMake(point.y, point.x);

  } else {
    return point;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)arrayIndexForPageIndex:(NSInteger)pageIndex relativeToIndex:(NSInteger)baseIndex {
  NSInteger numberOfPages = self.numberOfPages;
  if (0 == numberOfPages || pageIndex >= numberOfPages || pageIndex < 0) {
    return kInvalidIndex;
  }

  NSInteger indexDiff = pageIndex - baseIndex;
  if (fabs(indexDiff) > kOffscreenPages) {
    return kInvalidIndex;
  }

  NSInteger arrayIndex = _pageArrayIndex + indexDiff;

  if (arrayIndex >= _maxPages) {
    return arrayIndex - _maxPages;

  } else if (arrayIndex < 0) {
    return _maxPages + arrayIndex;

  } else {
    return arrayIndex;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)realPageIndex {
  if (self.pinched) {
    return _centerPageIndex;

  } else if (!self.flipped) {
    if (_pageEdges.left > kFlickThreshold && ![self isFirstPage]) {
      return _centerPageIndex - 1;

    } else if (_pageEdges.right < -kFlickThreshold && ![self isLastPage]) {
      return _centerPageIndex + 1;

    } else {
      return _centerPageIndex;
    }

  } else {
    if (_pageEdges.left > kFlickThreshold && ![self isLastPage]) {
      return _centerPageIndex + 1;

    } else if (_pageEdges.right < -kFlickThreshold && ![self isFirstPage]) {
      return _centerPageIndex - 1;

    } else {
      return _centerPageIndex;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)pageAtIndex:(NSInteger)pageIndex create:(BOOL)create {
  NSInteger arrayIndex = [self arrayIndexForPageIndex:pageIndex relativeToIndex:_centerPageIndex];
  if (arrayIndex == kInvalidIndex) {
    return nil;
  }

  UIView* page = [_pages objectAtIndex:arrayIndex];
  if ((NSNull*)page == [NSNull null]) {
    if (create) {
      page = [_dataSource scrollView:self pageAtIndex:pageIndex];
      page.multipleTouchEnabled = YES;
      page.userInteractionEnabled = YES;
      [self addSubview:page];
      [_pages replaceObjectAtIndex:arrayIndex withObject:page];

    } else {
      return nil;
    }
  }

  return page;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)enqueuePageAtIndex:(NSInteger)pageIndex {
  NSInteger arrayIndex = [self arrayIndexForPageIndex:pageIndex relativeToIndex:_centerPageIndex];
  if (arrayIndex == kInvalidIndex) {
    return nil;
  }

  UIView* page = [_pages objectAtIndex:arrayIndex];

  if ((NSNull*)page == [NSNull null]) {
    return nil;

  } else {
    [_pageQueue addObject:page];
    [_pages replaceObjectAtIndex:arrayIndex withObject:[NSNull null]];
    [page removeFromSuperview];
  }

  return page;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)enqueueAllPages {
  for (NSInteger i = 0; i < _pages.count; ++i) {
    UIView* page = [_pages objectAtIndex:i];

    if ((NSNull*)page != [NSNull null]) {
      [_pageQueue addObject:page];
      [_pages replaceObjectAtIndex:i withObject:[NSNull null]];
      [page removeFromSuperview];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)adjustPageEdgesForPageAtIndex:(NSInteger)pageIndex {
  CGRect centerFrame = [self frameOfPageAtIndex:_centerPageIndex];
  CGFloat centerPageOverflow = [self overflowForFrame:centerFrame] * self.zoomFactor;
  CGRect frame = [self frameOfPageAtIndex:pageIndex];
  CGFloat overflow = [self overflowForFrame:frame];

  if (self.flipped) {
    CGFloat factor = _centerPageIndex > pageIndex ? -1 : 1;
    CGFloat xd =  (self.pageWidth + _pageSpacing + centerPageOverflow + overflow) * factor;
    CGFloat left = _pageEdges.right > 0 ? _pageEdges.right : _pageEdges.left;
    CGFloat right = _pageEdges.left < 0 ? _pageEdges.left : _pageEdges.right;
    _pageEdges = _pageStartEdges = UIEdgeInsetsMake(0, left - xd, 0, right - xd);

  } else {
    CGFloat factor = _centerPageIndex > pageIndex ? 1 : -1;
    CGFloat xd =  (self.pageWidth + _pageSpacing + centerPageOverflow + overflow) * factor;
    CGFloat left = _pageEdges.right < 0 ? _pageEdges.right : _pageEdges.left;
    CGFloat right = _pageEdges.left > 0 ? _pageEdges.left : _pageEdges.right;
    _pageEdges = _pageStartEdges = UIEdgeInsetsMake(0, right - xd, 0, left - xd);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPageAtIndex:(NSInteger)pageIndex resetEdges:(BOOL)resetEdges animated:(BOOL)animated {
  if (resetEdges) {
    _pageEdges = _pageStartEdges = UIEdgeInsetsZero;
    _zooming = NO;
    [self setNeedsLayout];

  } else if (pageIndex != _centerPageIndex) {
    [self adjustPageEdgesForPageAtIndex:pageIndex];
    _zooming = NO;
  }

  NSInteger indexDiff = pageIndex - _centerPageIndex;
  if (indexDiff) {
    if (fabs(indexDiff) <= kOffscreenPages) {
      if (indexDiff > 0) {
        NSInteger edgeIndex = _centerPageIndex - kOffscreenPages;
        NSInteger newEdgeIndex = pageIndex - kOffscreenPages;
        for (int i = edgeIndex; i < newEdgeIndex; ++i) {
          [self enqueuePageAtIndex:i];
        }

      } else if (indexDiff < 0) {
        NSInteger edgeIndex = _centerPageIndex + kOffscreenPages;
        NSInteger newEdgeIndex = pageIndex + kOffscreenPages;
        for (int i = edgeIndex; i > newEdgeIndex; --i) {
          [self enqueuePageAtIndex:i];
        }
      }

    } else {
      [self reloadData];
    }

    _pageArrayIndex = [self arrayIndexForPageIndex:pageIndex relativeToIndex:_centerPageIndex];
    _centerPageIndex = pageIndex;
    [self setNeedsLayout];

    // Should animate the next relayout?
    _nextLayoutAnimated = animated;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPageAtIndex:(NSInteger)pageIndex resetEdges:(BOOL)resetEdges {
    [self moveToPageAtIndex:pageIndex resetEdges:resetEdges animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutPage {
  UIView* page = [self pageAtIndex:_centerPageIndex create:YES];

  // Layout.
  if (nil != page) {
    CGAffineTransform rotation = TTRotateTransformForOrientation(_orientation);
    CGPoint offset = [self offsetForOrientation:_pageEdges.left y:_pageEdges.top];
    CGRect frame = [self frameOfPageAtIndex:_centerPageIndex];

    if (self.zoomed) {
      CGFloat zoom = self.zoomFactor;

      page.transform = [self rotateTransform:CGAffineTransformScale(
        CGAffineTransformMakeTranslation(offset.x, offset.y), zoom, zoom)];

      // Should animate the relayout?
      if ( _nextLayoutAnimated ) {
        [UIView beginAnimations:@"pageAnimation" context:nil];
        [UIView setAnimationDuration:_centerPageAnimationDuration];
      }
      page.frame = CGRectMake(offset.x + frame.origin.x*zoom, offset.y + frame.origin.y*zoom,
        frame.size.width*zoom, frame.size.height*zoom);

      // Should animate the relayout?
      if ( _nextLayoutAnimated ) {
        [UIView commitAnimations];
      }

    } else {

      page.transform = rotation;

      // Should animate the relayout?
      if ( _nextLayoutAnimated ) {
        [UIView beginAnimations:@"pageAnimation" context:nil];
        [UIView setAnimationDuration:_centerPageAnimationDuration];
      }

      page.frame = CGRectMake(offset.x + frame.origin.x, offset.y + frame.origin.y,
        frame.size.width, frame.size.height);

      // Should animate the relayout?
      if ( _nextLayoutAnimated ) {
        [UIView commitAnimations];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutAdjacentPages {
  BOOL flipped = self.flipped;
  BOOL pinched = self.pinched;
  CGAffineTransform rotation = TTRotateTransformForOrientation(_orientation);

  NSInteger minPageIndex = _centerPageIndex - kOffscreenPages;
  NSInteger maxPageIndex = _centerPageIndex + kOffscreenPages;

  // Determine the direction.
  BOOL isGoingLeft = _centerPageIndex < _visiblePageIndex;

  CGRect centerFrame = [self frameOfPageAtIndex:_centerPageIndex];
  CGFloat centerPageOverflow = [self overflowForFrame:centerFrame] * self.zoomFactor;

  CGFloat overflow = centerPageOverflow;
  for (NSInteger i = _centerPageIndex - 1; i >= 0 && i >= minPageIndex; --i) {
    UIView* page = [self pageAtIndex:i create:YES];
    if (page) {
      CGRect frame = [self frameOfPageAtIndex:i];
      overflow += [self overflowForFrame:frame];

      NSInteger relativeIndex = -(_centerPageIndex - i);
      CGFloat x = flipped
        ? ((self.pageWidth + _pageSpacing) * -relativeIndex) + _pageEdges.right + overflow
        : ((self.pageWidth + _pageSpacing) * relativeIndex) + _pageEdges.left - overflow;
      CGPoint offset = [self offsetForOrientation:x y:0];

      page.transform = rotation;

      // Should animate the the "going right" relayout?
      if ( _nextLayoutAnimated && !isGoingLeft ) {
        [UIView beginAnimations:@"pageAnimation" context:nil];
        [UIView setAnimationDuration:_centerPageAnimationDuration];
      }

      page.frame = CGRectMake(offset.x + frame.origin.x, offset.y + frame.origin.y,
        frame.size.width, frame.size.height);
      page.hidden = pinched;

      // Should animate the the "going right" relayout?
      if ( _nextLayoutAnimated && !isGoingLeft) {
        [UIView commitAnimations];
      }
    }
  }

  overflow = centerPageOverflow;
  NSInteger pageCount = [_dataSource numberOfPagesInScrollView:self];
  for (NSInteger i = _centerPageIndex + 1; i < pageCount && i <= maxPageIndex; ++i) {
    UIView* page = [self pageAtIndex:i create:YES];
    if (page) {
      CGRect frame = [self frameOfPageAtIndex:i];
      overflow += [self overflowForFrame:frame];

      NSInteger relativeIndex = i - _centerPageIndex;
      CGFloat x = flipped
        ? ((self.pageWidth + _pageSpacing) * -relativeIndex) + _pageEdges.left - overflow
        : ((self.pageWidth + _pageSpacing) * relativeIndex) + _pageEdges.right + overflow;
      CGPoint offset = [self offsetForOrientation:x y:0];

      page.transform = rotation;

      // Should animate the "going left" relayout?
      if ( _nextLayoutAnimated && isGoingLeft ) {
        [UIView beginAnimations:@"pageAnimation" context:nil];
        [UIView setAnimationDuration:_centerPageAnimationDuration];
      }

      page.frame = CGRectMake(offset.x + frame.origin.x, offset.y + frame.origin.y,
        frame.size.width, frame.size.height);
      page.hidden = pinched;

      // Should animate the "going left" relayout?
      if ( _nextLayoutAnimated && isGoingLeft) {
        [UIView commitAnimations];
      }

    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)stretchTouchEdges:(UIEdgeInsets)edges toPoint:(CGPoint)point {
  UIEdgeInsets newEdges = edges;
  if (!edges.left || point.x < edges.left) {
    newEdges.left = point.x;
  }
  if (!edges.right || point.x > edges.right) {
    newEdges.right = point.x;
  }
  if (!edges.top || point.y < edges.top) {
    newEdges.top = point.y;
  }
  if (!edges.bottom || point.y > edges.bottom) {
    newEdges.bottom = point.y;
  }

  return newEdges;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)touchEdgesForPoint:(CGPoint)point {
  return [self stretchTouchEdges:UIEdgeInsetsZero toPoint:point];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)squareTouchEdges:(UIEdgeInsets)edges {
  //if (_touchCount == 1) {
    return edges;

  //} else {
  // ********
  //
  //    This math isn't used anymore since we rewrote the zoom engine.
  //    Still here, for reference and nothing more.
  //
    /* CGFloat width = edges.right - edges.left;
    CGFloat height = edges.bottom - edges.top;
    CGFloat d = sqrt((width*width) + (height*height));
    CGFloat midX = edges.left + (width/1.3);
    CGFloat midY = edges.top + (height/1.3);

    return UIEdgeInsetsMake(midY - d/2, midX - d/2, midY + d/2, midX + d/2);*/
  //}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)zoomPageEdgesTo:(CGPoint)point {
// ********
//
//    This math isn't used anymore since we rewrote the zoom engine.
//    Still here, for reference and nothing more.
/*

  UIEdgeInsets edges = _pageEdges;

  CGFloat zoom = kTapZoom * self.pageWidth;
  CGFloat r = self.pageHeight / self.pageWidth;

  CGFloat xd = self.pageWidth/2 - point.x;
  CGFloat yd = self.pageHeight/2 - point.y;

  edges.left = (-zoom + xd);
  edges.right = zoom + xd;
  edges.top = (-zoom + yd) * r;
  edges.bottom = (zoom + yd) * r;

  if (edges.left > 0) {
    edges.right += edges.left;
    edges.left = 0;

  } else if (edges.right < 0) {
    edges.left += -edges.right;
    edges.right = 0;
  }

  if (edges.top > 0) {
    edges.bottom += edges.top;
    edges.top = 0;

  } else if (edges.bottom < 0) {
    edges.top += -edges.bottom;
    edges.bottom = 0;
  }
*/
  return UIEdgeInsetsZero;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)reversePageEdges {
  UIEdgeInsets edges = _pageEdges;

  edges.left = -edges.left;
  edges.right = -edges.right;
  edges.top = -edges.top;
  edges.bottom = -edges.bottom;

  return edges;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)constrainEdges:(UIEdgeInsets)edges toWidth:(CGFloat)constrainedWidth {
  CGFloat constrainedHeight = constrainedWidth * (self.pageHeight/self.pageWidth);

  CGFloat height = -edges.top + self.pageHeight + edges.bottom;
  CGFloat width = -edges.left + self.pageWidth + edges.right;

  CGFloat xd = constrainedWidth - width;
  CGFloat yd = constrainedHeight - height;

  return UIEdgeInsetsMake(edges.top - yd/2, edges.left - xd/2,
    edges.bottom + yd/2, edges.right + xd/2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)resist:(CGFloat)x1 to:(CGFloat)x2 max:(CGFloat)max {
  // The closer we get to the maximum, the less we are allowed to increment
  CGFloat rl = (1 - (fabs(x2) / max)) * kResistance;
  if (rl < 0) rl = 0;
  if (rl > 1) rl = 1;
  return x1 + ((x2 - x1) * rl);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)resistPageEdges:(UIEdgeInsets)edges {
  CGFloat left = edges.left, right = edges.right, top = edges.top, bottom = edges.bottom;
  CGFloat width = self.pageWidth, height = self.pageHeight;

  if (-left + right < 0 || -top + bottom < 0) {
    CGFloat zoom = self.zoomFactor;
    left = [self resist:_pageEdges.left to:left max:width * zoom];
    right = [self resist:_pageEdges.right to:right max:width * zoom];
    top = [self resist:_pageEdges.top to:top max:height * zoom];
    bottom = [self resist:_pageEdges.bottom to:bottom max:height * zoom];

  } else {
    if (_touchCount == 2 || self.zoomed) {
      if (top > 0) {
        top = [self resist:_pageEdges.top to:top max:height];
        if (_touchCount == 2) {
          bottom = bottom + (top - _pageEdges.top);

        } else {
          bottom = _pageEdges.bottom + (top - _pageEdges.top);
        }

        CGFloat newHeight = -top + height + bottom;
        CGFloat newWidth = (width/height) * newHeight;
        CGFloat xd = newWidth - (-left + width + right);
        left -= xd/2;
        right += xd/2;

      } else if (bottom < 0) {
        bottom = [self resist:_pageEdges.bottom to:bottom max:height];
        if (_touchCount == 2) {
          top = top + (bottom - _pageEdges.bottom);

        } else {
          top = _pageEdges.top + (bottom - _pageEdges.bottom);
        }

        CGFloat newHeight = -top + height + bottom;
        CGFloat newWidth = (width/height) * newHeight;
        CGFloat xd = newWidth - (-left + width + right);
        left -= xd/2;
        right += xd/2;
      }
    }

    BOOL flipped = self.flipped;
    BOOL flickPrevious = (!flipped && left > 0) || (flipped && left < 0);
    BOOL flickNext = (!flipped && right < 0) || (flipped && right > 0);
    if (flickPrevious && [self isFirstPage] && !self.zoomed) {
      left = [self resist:_pageEdges.left to:left max:width];
      if (_touchCount == 2) {
        right = right + (left - _pageEdges.left);

      } else {
        right = _pageEdges.right + (left - _pageEdges.left);
      }

      CGFloat newWidth = -left + width + right;
      CGFloat newHeight = (height/width) * newWidth;
      CGFloat yd = newHeight - (-top + height + bottom);
      top -= yd/2;
      bottom += yd/2;

    } else if (flickNext && [self isLastPage] && !self.zoomed) {
      right = [self resist:_pageEdges.right to:right max:width];
      if (_touchCount == 2) {
        left = left + (right - _pageEdges.right);

      } else {
        left = _pageEdges.left + (right - _pageEdges.right);
      }
      CGFloat newWidth = -left + width + right;
      CGFloat newHeight = (height/width) * newWidth;
      CGFloat yd = newHeight - (-top + height + bottom);
      top -= yd/2;
      bottom += yd/2;
    }
  }

  return UIEdgeInsetsMake(top, left, bottom, right);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)pageEdgesForAnimation {
  CGFloat left = 0, right = 0, top = 0, bottom = 0;

  if (self.pinched) {
    left = -_pageEdges.left;
    right = -_pageEdges.right;
    top = -_pageEdges.top;
    bottom = -_pageEdges.bottom;

  } else if (self.flicked) {
    CGRect centerFrame = [self frameOfPageAtIndex:_centerPageIndex];
    CGFloat centerPageOverflow = [self overflowForFrame:centerFrame] * self.zoomFactor;

    if (_pageEdges.left < 0) {
      CGRect frame = [self frameOfPageAtIndex:_centerPageIndex + (self.flipped ? -1 : 1)];
      CGFloat overflow = centerPageOverflow + [self overflowForFrame:frame];
      if (fabs(_pageStartEdges.left) >= fabs(_pageEdges.right)) {
        left = right = -((self.pageWidth + _pageSpacing)
                         + _pageEdges.right + _overshoot + overflow);

      } else {
        left = right = -((self.pageWidth + _pageSpacing)
                         + _pageEdges.left + _overshoot + overflow);
      }

    } else {
      CGRect frame = [self frameOfPageAtIndex:_centerPageIndex + (self.flipped ? 1 : -1)];
      CGFloat overflow = centerPageOverflow + [self overflowForFrame:frame];
      if (fabs(_pageEdges.left) >= fabs(_pageEdges.right)) {
        left = right = ((self.pageWidth + _pageSpacing)
                        - _pageEdges.right + _overshoot + overflow);

      } else {
        left = right = ((self.pageWidth + _pageSpacing)
                        - _pageEdges.left + _overshoot + overflow);
      }
    }

  } else {
    if (_pageEdges.left > 0) {
      left = right = -_pageEdges.left;

    } else if (_pageEdges.right < 0) {
      left = right = -_pageEdges.right;
    }

    if (_pageEdges.top > 0) {
      top = bottom = -_pageEdges.top;

    } else if (_pageEdges.bottom < 0) {
      top = bottom = -_pageEdges.bottom;
    }
  }

  return UIEdgeInsetsMake(top, left, bottom, right);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)acquireTouch:(UITouch*)touch {
  if (nil == _touch1) {
    TT_RELEASE_SAFELY(_touch1);
    _touch1 = [touch retain];
    ++_touchCount;

  } else if (nil == _touch2) {
    TT_RELEASE_SAFELY(_touch2);
    _touch2 = [touch retain];
    ++_touchCount;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITouch*)removeTouch:(UITouch*)touch {
  if (touch == _touch1) {
    TT_RELEASE_SAFELY(_touch1);
    --_touchCount;
    return _touch2;

  } else if (touch == _touch2) {
    TT_RELEASE_SAFELY(_touch2);
    --_touchCount;
    return _touch1;

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canZoom {
  return _zoomEnabled && !_holding
        && (_zooming || ![_delegate respondsToSelector:@selector(scrollViewShouldZoom:)]
            || [_delegate scrollViewShouldZoom:self]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)edgesAreZoomed:(UIEdgeInsets)edges {
  return edges.left != edges.right || edges.top != edges.bottom;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateZooming:(UIEdgeInsets)edges {
  if (!_zooming && (self.zoomed || [self edgesAreZoomed:edges])) {
    _zooming = YES;
    self.centerPage.userInteractionEnabled = NO;

    if ([_delegate respondsToSelector:@selector(scrollViewDidBeginZooming:)]) {
      [_delegate scrollViewDidBeginZooming:self];
    }

  } else if (_zooming && !self.zoomed) {
    _zooming = NO;
    self.centerPage.userInteractionEnabled = YES;

    if ([_delegate respondsToSelector:@selector(scrollViewDidEndZooming:)]) {
      [_delegate scrollViewDidEndZooming:self];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopDragging:(BOOL)willDecelerate {
  if (_dragging) {
    _dragging = NO;

    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
      [_delegate scrollViewDidEndDragging:self willDecelerate:willDecelerate];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)rotationDidStop {
  if ([_delegate respondsToSelector:@selector(scrollViewDidRotate:)]) {
    [_delegate scrollViewDidRotate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startTapTimer:(UITouch*)touch {
  _tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tapTimer:)
    userInfo:touch repeats:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tapTimer:(NSTimer*)timer {
  _tapTimer = nil;

  if ([_delegate respondsToSelector:@selector(scrollView:tapped:)]) {
    UITouch* touch = timer.userInfo;
    [_delegate scrollView:self tapped:touch];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Begin the "holding" action on the view.
 * This occurs after the number of seconds defined by _holdsAfterTouchingForInterval.
 */
- (void)beginHolding {
  _holdingTimer = nil;
  _holding = YES;

  if ([_delegate respondsToSelector:@selector(scrollViewDidBeginHolding:)]) {
    [_delegate scrollViewDidBeginHolding:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endHolding {
  _holding = NO;

  if ([_delegate respondsToSelector:@selector(scrollViewDidEndHolding:)]) {
    [_delegate scrollViewDidEndHolding:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)holdingTimer:(NSTimer*)timer {
  _holdingTimer = nil;
  [self beginHolding];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startAnimationTo:(UIEdgeInsets)edges duration:(NSTimeInterval)duration {
  if (!_animationTimer) {
    _pageStartEdges = _pageEdges;
    [self updateZooming:edges];
    TT_INVALIDATE_TIMER(_tapTimer);

    _animateEdges = edges;
    _animationDuration = duration;
    _animationStartTime = [[NSDate date] retain];
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:kFrameDuration target:self
      selector:@selector(animator) userInfo:nil repeats:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAnimation:(BOOL)resetEdges {
  if (_animationTimer) {
    [_animationTimer invalidate];
    _animationTimer = nil;
    TT_RELEASE_SAFELY(_animationStartTime);
    _overshoot = 0;
    [self updateZooming:UIEdgeInsetsZero];

    NSInteger realIndex = [self realPageIndex];
    if (realIndex != _centerPageIndex || self.pinched) {
      [self moveToPageAtIndex:realIndex resetEdges:resetEdges];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tween:(NSTimeInterval)t b:(NSTimeInterval)b c:(NSTimeInterval)c d:(NSTimeInterval)d {
  t = t/d-1;
  return c*(t*t*t + 1) + b;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animator {
  NSTimeInterval kt = -[_animationStartTime timeIntervalSinceNow];
  CGFloat pct = kt ? [self tween:kt b:0 c:kt d:_animationDuration]/kt : 0;
  if (pct > 1.0) {
    pct = 1.0;
  }

  _pageEdges.left = _pageStartEdges.left + _animateEdges.left * pct;
  _pageEdges.right = _pageStartEdges.right + _animateEdges.right * pct;
  _pageEdges.top = _pageStartEdges.top + _animateEdges.top * pct;
  _pageEdges.bottom = _pageStartEdges.bottom + _animateEdges.bottom * pct;

  [self setNeedsLayout];

  if (pct == 1.0) {
    [self layoutIfNeeded];

    if (_overshoot) {
      TT_RELEASE_SAFELY(_animationStartTime);
      [_animationTimer invalidate];
      _animationTimer = nil;
      [self startAnimationTo:UIEdgeInsetsMake(0, self.overshoot, 0, self.overshoot) duration:0.1];
      _overshoot = 0;

    } else {
      [self stopAnimation:NO];

      if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:self];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * This method isn't being used anywhere.
 */
- (void)animator2 {
  NSTimeInterval kt = -[_animationStartTime timeIntervalSinceNow];
  CGFloat pct = kt ? [self tween:kt b:0 c:kt d:_animationDuration]/kt : 0;
  if (pct > 1.0) {
    pct = 1.0;
  }

  _pageEdges.left = _pageStartEdges.left + _animateEdges.left * pct;
  _pageEdges.right = _pageStartEdges.right + _animateEdges.right * pct;
  _pageEdges.top = _pageStartEdges.top + _animateEdges.top * pct;
  _pageEdges.bottom = _pageStartEdges.bottom + _animateEdges.bottom * pct;

  [self setNeedsLayout];

  if (pct == 1.0) {
    [self layoutIfNeeded];
    [self stopAnimation:YES];

    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
      [_delegate scrollViewDidEndDecelerating:self];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Animate deceleration.
 */
-(void)inertiaAnimator {
  // Inertia, slowing the speed. If are pulled, double inertia (Slow MUCH faster).
  _inertiaSpeed.x *= (self.pulled ? _decelerationRate / 2 : _decelerationRate);
  _inertiaSpeed.y *= (self.pulled ? _decelerationRate / 2 : _decelerationRate);

  // Calculate Edges based on Speed.
  CGFloat top    = _pageEdges.top + _inertiaSpeed.y;
  CGFloat left  = _pageEdges.left + _inertiaSpeed.x;
  CGFloat right  = _pageEdges.right + _inertiaSpeed.x;
  CGFloat bottom  = _pageEdges.bottom + _inertiaSpeed.y;

  // Format New Edges.
  UIEdgeInsets newEdges = UIEdgeInsetsMake(top, left, bottom, right);

  // Update Zooming.
  [self updateZooming:newEdges];

  // Apply New Edges and Relayout.
  _pageEdges = newEdges; [self setNeedsLayout];

  // Neligible speed, stop.
  if (abs(_inertiaSpeed.x) < 0.05 && abs(_inertiaSpeed.y) < 0.05) {
    // Stop animator.
    [self stopAnimation:NO];

    // Reset.
    _decelerating = NO;
    _inertiaSpeed = CGPointZero;

    // Warn delegate.
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
      [_delegate scrollViewDidEndDecelerating:self];
    }

    // Return to NORMAL BOUNDS, animated.
    if ((self.pinched || (_touchCount == 0 && self.pulled)) && self.scrollEnabled) {
      UIEdgeInsets edges = [self pageEdgesForAnimation];
      NSTimeInterval dur = self.flicked ? kFlickDuration : kBounceDuration;
      [self startAnimationTo:edges duration:dur];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGPoint)midpointBetweenPointA:(CGPoint)a andB:(CGPoint)b {
    return CGPointMake((a.x + b.x) / 2.0,
             (a.y + b.y) / 2.0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)distanceBetweenPointA:(CGPoint)a andB:(CGPoint)b {
  CGFloat deltaX = b.x - a.x;
  CGFloat deltaY = b.y - a.y;
  return sqrt(deltaX*deltaX + deltaY*deltaY );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)calculateZoomScaleUsingFingerDistances {

  // Distance Between Fingers.
  distanceBetweenFingers = [self distanceBetweenPointA:[self touchLocation:_touch1]
                          andB:[self touchLocation:_touch2]];

  // If Actual distance is 0, assume current distance.
  actualDistanceBetweenFingers = (actualDistanceBetweenFingers == 0.0 ?
                  distanceBetweenFingers : actualDistanceBetweenFingers);

  // Zoom Scale Speed and Direction.
  // This math calculate the zoom speed based on how fast your fingers move.
  CGFloat zoomScaleSpeed = ( distanceBetweenFingers / actualDistanceBetweenFingers );

  // Increase/Decrease The Zoom Factor (Scale) Using Calculated Speed Rate.
  CGFloat newScale = self.zoomFactor * zoomScaleSpeed;

  // Save Actual Distance. So If the Fingers "change" direction or distance we'll know.
  actualDistanceBetweenFingers = distanceBetweenFingers;

  // Check Scale. If is bigger assume maximumScale.
  newScale = ( newScale > _maximumZoomScale ? _maximumZoomScale : newScale );

  // Return New Scale.
  return newScale;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)squareEdgesUsingZoomScale:(CGFloat)newScale andAnchorPoint:(CGPoint)anchorPoint {
  UIEdgeInsets edges = UIEdgeInsetsZero;

  // Calc New Width and Height (Scaled by factor).
  CGSize newStretched = CGSizeMake(floor(self.pageWidth * newScale),
                   floor(self.pageHeight * newScale));

  // We have TWO anchor points. One for the normal frame of the screen.
  // And another to the BOUNDS of the scaled image, including "hided" parts.
  // This two coordinates are crossed and aligned using % on both axis.

  // Anchor Point at SCALED coordinates.
  CGPoint scaledAnchorPoint = CGPointMake((-_pageEdges.left) + anchorPoint.x,
                      (-_pageEdges.top) + anchorPoint.y);

  // Equivalent to the % of the anchor point positon on his axis. (NOT SCALED)
  CGPoint normalRanges = CGPointMake(anchorPoint.x / 1 / self.pageWidth,
                     anchorPoint.y / 1 / self.pageHeight);

  // Equivalent to the % of the anchor point positon on his axis. (SCALED)
  CGPoint scaledRanges = CGPointMake(scaledAnchorPoint.x / 1 / self.stretchedWidth,
                     scaledAnchorPoint.y / 1 / self.stretchedHeight);


  //
  // New Edges.
  //
  // We need to perfect align the two centers (scaled and not scaled). Them we have our
  // left and top edges.
  // This allows zoom in/out from a specific finger-point on every zoom level.
  //
  edges.left   = -((newStretched.width * scaledRanges.x) - (self.pageWidth * normalRanges.x));
  edges.top    = -((newStretched.height * scaledRanges.y) - (self.pageHeight * normalRanges.y));

  edges.right  = newStretched.width - (-edges.left + self.pageWidth);
  edges.bottom = newStretched.height - (-edges.top + self.pageHeight);

  /*** DEBUG *

  NSLog( @"page-with: %f", self.pageWidth );
  NSLog( @"resized-width: %f", newStretched.width);
  NSLog( @"old-width: %f", self.stretchedWidth);
  NSLog( @"actual left: %f", _pageEdges.left );
  NSLog( @"actual right: %f", _pageEdges.right );
  NSLog( @"touch: %f", anchorPoint.x);
  NSLog( @"point: %f", anchorPoint.x);
  NSLog( @"B: %f", scaledRanges.x);
  NSLog( @"C: %f", normalRanges.x);
  NSLog( @"left: %f", edges.left);
  NSLog( @"right: %f", edges.right);
  NSLog( @"/////////////////////////////////////////////////////////////////////////////////");

  */

  return edges;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)squareEdgesUsingFingerDistancesAndAnchorPoint:(CGPoint)anchorPoint {
  return [self squareEdgesUsingZoomScale:[self calculateZoomScaleUsingFingerDistances]
              andAnchorPoint:anchorPoint];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Solution for the issue discussed here:
 * http://discussions.apple.com/message.jspa?messageID=7139722
 */
- (void) ensureTouches {
  if (_touch1.phase == UITouchPhaseEnded) {
    [self removeTouch: _touch1];
  }
  if (_touch2.phase == UITouchPhaseEnded) {
    [self removeTouch: _touch2];
  }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesBegan:touches withEvent:event];

  [self ensureTouches];

  if (_touchCount < 2) {
    [self stopAnimation:NO];

    for (UITouch* touch in touches) {
      [self acquireTouch:touch];

      if (_touchCount == 1) {
        if ([_delegate respondsToSelector:@selector(scrollView:touchedDown:)]) {
          [_delegate scrollView:self touchedDown:touch];
        }

        if (_holdsAfterTouchingForInterval) {
          _holdingTimer = [NSTimer scheduledTimerWithTimeInterval:_holdsAfterTouchingForInterval
                                   target:self selector:@selector(holdingTimer:)
                                   userInfo:nil repeats:NO];
        }

        if (_scrollEnabled && !_holding) {
          CGPoint pt = [self touchLocation:touch];
          _touchStartEdges = _touchEdges = [self touchEdgesForPoint:pt];
          _pageStartEdges  = _pageEdges;
          _renewPosition   = CGPointMake(_touchStartEdges.left, _touchStartEdges.top);
        }

      } else if (_touchCount == 2) {
        if (_scrollEnabled && !_holding) {
          CGPoint pt = [self touchLocation:touch];
          _touchEdges = [self squareTouchEdges:[self stretchTouchEdges:_touchEdges toPoint:pt]];
          _touchStartEdges = _touchEdges;
          _pageStartEdges = _pageEdges;
        }
      }

      if (touch.tapCount == 2) {
        TT_INVALIDATE_TIMER(_tapTimer);
      }
    }

    // Reset Actual Distance.
    actualDistanceBetweenFingers = 0.0;

    // Store middle point between fingers.
    if (_touchCount == 2) {
      centerOfFingers = [self midpointBetweenPointA:[self touchLocation:_touch1]
                           andB:[self touchLocation:_touch2]];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  TT_INVALIDATE_TIMER(_holdingTimer);

  if (_scrollEnabled && !_holding && _touchCount && !_animationTimer) {
    if (!_dragging) {
      _dragging = YES;
      TT_INVALIDATE_TIMER(_tapTimer);

      if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:self];
      }
    }

    _touchEdges = UIEdgeInsetsZero;
    for (UITouch* touch in [event allTouches]) {
      if (touch == _touch1 || touch == _touch2) {
        _touchEdges = [self stretchTouchEdges:_touchEdges toPoint:[self touchLocation:touch]];
      }
    }

    // Declare common.
    UIEdgeInsets pageEdges = UIEdgeInsetsZero;
    UIEdgeInsets newEdges = UIEdgeInsetsZero;

    UIEdgeInsets edges = [self squareTouchEdges:_touchEdges];
    CGFloat left = _pageStartEdges.left + (edges.left - _touchStartEdges.left);
    CGFloat right = _pageStartEdges.right + (edges.right - _touchStartEdges.right);
    CGFloat top = _pageEdges.top;
    CGFloat bottom = _pageEdges.bottom;

    // Drag when is zoomed correct bottom and top.
    if ((_touchCount == 2 || self.zoomed) && _zoomEnabled && !_holding) {
      top = _pageStartEdges.top + (edges.top - _touchStartEdges.top);
      bottom = _pageStartEdges.bottom + (edges.bottom - _touchStartEdges.bottom);
    }

    // Zooming.
    if (_touchCount == 2 && _zoomEnabled && !_holding) {
      // Calc.
      newEdges  = [self squareEdgesUsingFingerDistancesAndAnchorPoint:centerOfFingers];
      pageEdges = [self resistPageEdges:newEdges];
      _executingZoomGesture = YES;

    // Dragging.

    } else if ( _touchCount == 1 ) {
      newEdges  = UIEdgeInsetsMake(top, left, bottom, right);
      pageEdges = [self resistPageEdges:newEdges];
      _executingZoomGesture = NO;
    }

    // Calculate distance. (Speed).
    _inertiaSpeed = CGPointMake(_touchEdges.left - _renewPosition.x,
                                _touchEdges.top - _renewPosition.y);

    // Renew.
    _renewPosition = CGPointMake(_touchEdges.left, _touchEdges.top);

    if (![self edgesAreZoomed:pageEdges] || self.canZoom) {
      _pageEdges = pageEdges;
      [self updateZooming:pageEdges];
      [self setNeedsLayout];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  TT_INVALIDATE_TIMER(_holdingTimer);

  for (UITouch* touch in touches) {
    [self removeTouch:touch];
  }

  if (!_touchCount) {
    [self stopAnimation:YES];
    [self stopDragging:NO];
    [self updateZooming:UIEdgeInsetsZero];

    _pageEdges = UIEdgeInsetsZero;
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesEnded:touches withEvent:event];
  TT_INVALIDATE_TIMER(_holdingTimer);
  if (_holding) {
    [self endHolding];
  }

  for (UITouch* touch in touches) {
    if (touch == _touch1 || touch == _touch2) {
      UITouch* remainingTouch = [self removeTouch:touch];

      if (_touchCount == 1) {
        CGPoint point = [self touchLocation:remainingTouch];
        _touchEdges = _touchStartEdges = [self touchEdgesForPoint:point];
        _pageStartEdges = _pageEdges;
        _renewPosition = CGPointMake(_touchEdges.left, _touchEdges.top);
        _executingZoomGesture = NO;

      } else if (_touchCount == 0) {

        if (touch.tapCount == 1 && !_dragging) {
          _executingZoomGesture = NO;
          if ([_delegate respondsToSelector:@selector(scrollView:touchedUpInside:)]) {
              [_delegate scrollView:self touchedUpInside:touch];
          }

          [self startTapTimer:touch];

        // Double tap, zoom out to fit or zoom in to the 1/3 of the maximum scale.

        } else if (touch.tapCount == 2 && self.canZoom) {
          CGPoint pointToZoom = [self touchLocation:touch];

          if (self.zoomed) {
            [self zoomToFit];

          } else {
            [self setZoomScale:_maximumZoomScale / 1.3  withPoint:pointToZoom animated:YES];
          }
        }

        // The scroll view will continue to move a short distance afterwards.
        // If are zoomed, will still moving after stop drag. Short distance, doesn't animate.
        if (_touchCount == 0 && self.scrollEnabled
            && self.zoomed && abs(_inertiaSpeed.x) >= 1 && abs(_inertiaSpeed.y) >= 1) {
          // Increase speed. (Longer residual movement).
          _inertiaSpeed.x *= kIncreaseSpeed;
          _inertiaSpeed.y *= kIncreaseSpeed;

          // Store actual Page Edges.
          _pageStartEdges = _pageEdges;

          // Warn delegate.
          if ([_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
            [_delegate scrollViewWillBeginDecelerating:self];
          }

          // Start Animation Timer.
          if (!_animationTimer) {
            _decelerating = YES;

            TT_INVALIDATE_TIMER(_tapTimer);
            _animationTimer = [NSTimer scheduledTimerWithTimeInterval:kFrameDuration target:self
                                     selector:@selector(inertiaAnimator) userInfo:nil repeats:YES];
          }
        }

        [self stopDragging:YES];
      }

      if ((self.pinched || (_touchCount == 0 && self.pulled)) && self.scrollEnabled) {
        UIEdgeInsets edges = [self pageEdgesForAnimation];
        NSTimeInterval dur = self.flicked ? kFlickDuration : kBounceDuration;
        //_overshoot = kOvershoot;
        [self startAnimationTo:edges duration:dur];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [self layoutPage];
  [self layoutAdjacentPages];

  if (_visiblePageIndex != _centerPageIndex && self.centerPage) {
    _visiblePageIndex = _centerPageIndex;
    [_delegate scrollView:self didMoveToPageAtIndex:_centerPageIndex];
  }

  // Reset the layout animated flag.
  _nextLayoutAnimated = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  if (!self.superview) {
    [self stopAnimation:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIDeviceOrientationDidChangeNotification


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)deviceOrientationDidChange:(void*)object {
//  UIInterfaceOrientation orientation = TTDeviceOrientation();
//  if (_rotateEnabled && !_holding
//      && (![_delegate
//            respondsToSelector:@selector(scrollView:shouldAutorotateToInterfaceOrientation:)]
//      || [_delegate scrollView:self shouldAutorotateToInterfaceOrientation:orientation])) {
//    self.orientation = orientation;
//  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)zoomed {
  return _pageEdges.left != _pageEdges.right || _pageEdges.top != _pageEdges.bottom;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<TTScrollViewDataSource>)dataSource {
  _dataSource = dataSource;
  [self reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPageIndex:(NSInteger)centerPageIndex animated:(BOOL)animated {
  // TODO: Fix limitation, for now only animate the distance of one page .. :(
  animated = ( _centerPageIndex-centerPageIndex >= -1 || _centerPageIndex+centerPageIndex <= 1 );

  [self moveToPageAtIndex:centerPageIndex resetEdges:!_touchCount animated:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPageIndex:(NSInteger)centerPageIndex {
  [self moveToPageAtIndex:centerPageIndex resetEdges:!_touchCount];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPages {
  return [_dataSource numberOfPagesInScrollView:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)centerPage {
  return [self pageAtIndex:_centerPageIndex create:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)visiblePages {
  NSMutableDictionary* visiblePages = [NSMutableDictionary dictionaryWithCapacity:_maxPages];

  UIView* centerPage = self.centerPage;
  if (centerPage) {
    [visiblePages setObject:self.centerPage forKey:[NSNumber numberWithInt:_centerPageIndex]];
  }

  NSInteger minPageIndex = _centerPageIndex - kOffscreenPages;
  for (NSInteger i = _centerPageIndex - 1; i >= 0 && i >= minPageIndex; --i) {
    UIView* page = [self pageAtIndex:i create:YES];
    if (page) {
      [visiblePages setObject:page forKey:[NSNumber numberWithInt:i]];
    }
  }

  NSInteger maxPageIndex = _centerPageIndex + kOffscreenPages;
  NSInteger pageCount = [_dataSource numberOfPagesInScrollView:self];
  for (NSInteger i = _centerPageIndex + 1; i < pageCount && i <= maxPageIndex; ++i) {
    UIView* page = [self pageAtIndex:i create:YES];
    if (page) {
      [visiblePages setObject:page forKey:[NSNumber numberWithInt:i]];
    }
  }

  return visiblePages;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrientation:(UIInterfaceOrientation)orientation {
  [self setOrientation:orientation animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
  if (orientation != _orientation && [self supportsOrientation:orientation]) {
    if ([_delegate respondsToSelector:@selector(scrollViewWillRotate:toOrientation:)]) {
      [_delegate scrollViewWillRotate:self toOrientation:orientation];
    }

    _orientation = orientation;

    if (animated) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:TT_TRANSITION_DURATION];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(rotationDidStop)];
      [self layoutPage];
      [UIView commitAnimations];

    } else {
      [self rotationDidStop];
      [self setNeedsLayout];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)dequeueReusablePage {
  if (_pageQueue.count) {
    UIView* page = [[_pageQueue.lastObject retain] autorelease];
    [_pageQueue removeLastObject];
    return page;

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
  if (_dataSource) {
    [self enqueueAllPages];

    _visiblePageIndex = kInvalidIndex;
    _pageEdges = _pageStartEdges = UIEdgeInsetsZero;

    [self cancelTouches];
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)pageAtIndex:(NSInteger)pageIndex {
  return [self pageAtIndex:pageIndex create:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A floating-point value that specifies the current scale factor applied to the scroll
 * view's content.
 */
-(CGFloat)zoomScale {
  return self.zoomFactor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A floating-point value that specifies the current zoom scale.
 */
-(void)setZoomScale:(CGFloat)scale {
  [self setZoomScale:scale animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A floating-point value that specifies the current zoom scale.
 */
- (void)setZoomScale:(CGFloat)newScale animated:(BOOL)animated {
  [self setZoomScale:newScale
       withPoint:CGPointMake(self.pageWidth / 2, self.pageHeight / 2)
        animated:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A floating-point value that specifies the current zoom scale.
 *
 * Specify one touch point, the scale occurrs centering to him.
 *
 * YES to animate the transition to the new scale, NO to make the transition immediate.
 */
- (void)setZoomScale:(CGFloat)newScale withPoint:(CGPoint)withPoint animated:(BOOL)animated {

  // If bigger than maximum scale or zoom disabled, do nothing.
  if ( newScale > _maximumZoomScale || !self.zoomEnabled ) return;

  // Square Edges to new scale, using specified anchor point.//
  UIEdgeInsets zoomEdges = [self squareEdgesUsingZoomScale:newScale
                        andAnchorPoint:withPoint];

  // If animated.
  if ( animated ) {
    [self startAnimationTo:zoomEdges duration:kBounceDuration];
  }

  // Not animated, just apply.
  else {
    UIEdgeInsets pageEdges = [self resistPageEdges:zoomEdges];
    if (![self edgesAreZoomed:pageEdges] || self.canZoom) {
      _pageEdges = pageEdges;
      [self updateZooming:pageEdges];
      [self setNeedsLayout];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)zoomToFit {
  [self startAnimationTo:[self reversePageEdges] duration:kBounceDuration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)zoomToDistance:(CGFloat)distance {
  UIEdgeInsets insets = UIEdgeInsetsMake(distance, distance, -1 * distance, -1 * distance);
  [self startAnimationTo:insets duration:kBounceDuration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelTouches {
  [self stopAnimation:YES];
  [self stopDragging:NO];
  [self updateZooming:UIEdgeInsetsZero];
  TT_RELEASE_SAFELY(_touch1);
  TT_RELEASE_SAFELY(_touch2);
  _touchCount = 0;
}


@end
