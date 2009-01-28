#import "Three20/T3ScrollView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#define T3_OFFSCREEN_PAGES 1
#define T3_MAX_PAGES ((T3_OFFSCREEN_PAGES*2) + 1)

static const CGFloat T3DefaultPageSpacing = 40.0;
static const CGFloat T3FlickThreshold = 60.0;
static const CGFloat T3DragResistance = 0.5;
static const CGFloat T3DragResistance2 = 0.15;
static const CGFloat T3TapZoom = 0.5;
static const CGFloat T3MinimumZoom = 0.75;
static const CGFloat T3MaximumZoom = 3.5;
static const NSInteger T3InvalidIndex = -1;
static const NSTimeInterval T3FlickInterval = 0.4;
static const NSTimeInterval T3BounceInterval = 0.5;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ScrollView

@synthesize delegate = _delegate, dataSource = _dataSource, currentPageIndex = _currentPageIndex,
  pageSpacing = _pageSpacing, scrollEnabled = _scrollEnabled, zoomEnabled = _zoomEnabled,
  rotateEnabled = _rotateEnabled, orientation = _orientation;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;
    
    _delegate = nil;
    _dataSource = nil;
    _pageViews = [[NSMutableArray alloc] initWithCapacity:T3_MAX_PAGES];
    _pageViewQueue = [[NSMutableArray alloc] init];
    _pageSpacing = T3DefaultPageSpacing;
    _currentPageIndex = 2;
    _pageArrayIndex = 0;
    _touchCount = 0;
    _pageEdges = UIEdgeInsetsZero;
    _pageStartEdges = UIEdgeInsetsZero;
    _touchEdges = UIEdgeInsetsZero;
    _touchStartEdges = UIEdgeInsetsZero;
    _scrollEnabled = YES;
    _zoomEnabled = YES;
    _rotateEnabled = YES;
    _orientation = T3DeviceOrientation();
    _touch1 = nil;
    _touch2 = nil;
    
    for (NSInteger i = 0; i < T3_MAX_PAGES; ++i) {
      [_pageViews addObject:[NSNull null]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(deviceOrientationDidChange:)
      name:@"UIDeviceOrientationDidChangeNotification" object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
    name:@"UIDeviceOrientationDidChangeNotification" object:nil];

  [_animationTimer invalidate];
  [_animationStartTime release];
  [_pageViews release];
  [_pageViewQueue release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isFirstPage {
  return _currentPageIndex == 0;
}

- (BOOL)isLastPage {
  return _currentPageIndex+1 >= [_dataSource numberOfItemsInScrollView:self];
}

- (BOOL)draggingFromEdge {
  return (_pageEdges.left < 0 && [self isLastPage]) || (_pageEdges.left > 0 && [self isFirstPage]);
}

- (BOOL)flipped {
  return _orientation == UIInterfaceOrientationLandscapeLeft
      || _orientation == UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)pinched {
  return -_pageEdges.left + _pageEdges.right < 0;
}

- (BOOL)pulled {
  return _pageEdges.left > 0 || _pageEdges.top > 0 || _pageEdges.right < 0 || _pageEdges.bottom < 0;
}

- (BOOL)zoomed {
  return _pageEdges.left != _pageEdges.right || _pageEdges.top != _pageEdges.bottom;
}

- (BOOL)flicked {
  if (!self.flipped) {
    if (_pageEdges.left > T3FlickThreshold && ![self isFirstPage]) {
      return YES;
    } else if (_pageEdges.right < -T3FlickThreshold && ![self isLastPage]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    if (_pageEdges.left > T3FlickThreshold && ![self isLastPage]) {
      return YES;
    } else if (_pageEdges.right < -T3FlickThreshold && ![self isFirstPage]) {
      return YES;
    } else {
      return NO;
    }
  }
}

- (CGFloat)pageWidth {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return self.height;
  } else {
    return self.width;
  }
}

- (CGFloat)pageHeight {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return self.width;
  } else {
    return self.height;
  }
}

- (CGRect)frameOfPageAtIndex:(NSInteger)pageIndex {
  if ([_dataSource respondsToSelector:@selector(scrollView:sizeOfPageAtIndex:)]) {
    CGSize size = [_dataSource scrollView:self sizeOfPageAtIndex:pageIndex];
    
    CGFloat width, height;
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
      if (size.width > size.height) {
        height = size.width/size.height * self.width;
        width = self.width;
      } else {
        height = size.width/size.height * self.width;
        width = self.width;
      }
    } else {
      if (size.width > size.height) {
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
  } else {
    return CGRectMake(0, 0, self.pageWidth, self.pageHeight);
  }
}

- (CGPoint)offsetForOrientation:(CGFloat)x y:(CGFloat)y {
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return CGPointMake(y, x);
  } else {
    return CGPointMake(x, y);
  }
}

- (BOOL)supportsOrientation:(UIInterfaceOrientation)orientation {
  return orientation == UIInterfaceOrientationLandscapeLeft
          || orientation == UIInterfaceOrientationLandscapeRight
          || orientation == UIInterfaceOrientationPortrait;
}

- (CGAffineTransform)rotateTransform:(CGAffineTransform)transform {
  if (_orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformRotate(transform, 4.71238898);
  } else if (_orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformRotate(transform, 1.57079633);
  } else {
    return transform;
  }
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(4.71238898);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(1.57079633);
  } else {
    return CGAffineTransformIdentity;
  }
}

- (CGPoint)touchLocation:(UITouch*)touch {
  CGPoint point = [touch locationInView:self];
  if (UIInterfaceOrientationIsLandscape(_orientation)) {
    return CGPointMake(point.y, point.x);
  } else {
    return point;
  }
}

- (NSInteger)pageIndexForItemIndex:(NSInteger)itemIndex relativeToIndex:(NSInteger)baseIndex {
  NSInteger indexDiff = itemIndex - baseIndex;
  if (abs(indexDiff) > T3_OFFSCREEN_PAGES) {
    return T3InvalidIndex;
  }
  NSInteger arrayIndex = _pageArrayIndex + indexDiff;
  if (arrayIndex >= T3_MAX_PAGES) {
      return arrayIndex - T3_MAX_PAGES;
  } else if (arrayIndex < 0) {
    return T3_MAX_PAGES + arrayIndex;
  } else {
    return arrayIndex;
  }
}

- (NSInteger)realPageIndex {
  if (self.pinched) {
    return _currentPageIndex;
  } else if (!self.flipped) {
    if (_pageEdges.left > T3FlickThreshold && ![self isFirstPage]) {
      return _currentPageIndex - 1;
    } else if (_pageEdges.right < -T3FlickThreshold && ![self isLastPage]) {
      return _currentPageIndex + 1;
    } else {
      return _currentPageIndex;
    }
  } else {
    if (_pageEdges.left > T3FlickThreshold && ![self isLastPage]) {
      return _currentPageIndex + 1;
    } else if (_pageEdges.right < -T3FlickThreshold && ![self isFirstPage]) {
      return _currentPageIndex - 1;
    } else {
      return _currentPageIndex;
    }
  }
}

- (UIView*)pageAtIndex:(NSInteger)index create:(BOOL)create {
  NSInteger arrayIndex = [self pageIndexForItemIndex:index relativeToIndex:_currentPageIndex];
  if (arrayIndex == T3InvalidIndex) {
    return nil;
  }
  
  UIView* pageView = [_pageViews objectAtIndex:arrayIndex];
  if ((NSNull*)pageView == [NSNull null]) {
    if (create) {
      pageView = [_dataSource scrollView:self pageAtIndex:index];
      pageView.userInteractionEnabled = NO;
      [self addSubview:pageView];
      [_pageViews replaceObjectAtIndex:arrayIndex withObject:pageView];
    } else {
      return nil;
    }
  }
  
  return pageView;
}

- (UIView*)enqueuePageAtIndex:(NSInteger)index {
  NSInteger arrayIndex = [self pageIndexForItemIndex:index relativeToIndex:_currentPageIndex];
  if (arrayIndex == T3InvalidIndex) {
    return nil;
  }
  
  UIView* pageView = [_pageViews objectAtIndex:arrayIndex];
  if ((NSNull*)pageView == [NSNull null]) {
    return nil;
  } else {
    [_pageViewQueue addObject:pageView];
    [_pageViews replaceObjectAtIndex:arrayIndex withObject:[NSNull null]];
  }
  
  return pageView;
}

- (void)enqueueAllPages {
  for (int i = 0; i < _pageViews.count; ++i) {
    [self enqueuePageAtIndex:i];
  }
}

- (void)adjustPageEdgesForPageAtIndex:(NSInteger)pageIndex {
  if (self.flipped) {
    CGFloat xd = (_currentPageIndex - pageIndex) * -(self.pageWidth + _pageSpacing);
    CGFloat left = _pageEdges.right > 0 ? _pageEdges.right : _pageEdges.left;
    CGFloat right = _pageEdges.left < 0 ? _pageEdges.left : _pageEdges.right;
    _pageEdges = _pageStartEdges = UIEdgeInsetsMake(0, left - xd, 0, right - xd);
  } else {
    CGFloat xd = (_currentPageIndex - pageIndex) * (self.pageWidth + _pageSpacing);
    CGFloat left = _pageEdges.right < 0 ? _pageEdges.right : _pageEdges.left;
    CGFloat right = _pageEdges.left > 0 ? _pageEdges.left : _pageEdges.right;
    _pageEdges = _pageStartEdges = UIEdgeInsetsMake(0, right - xd, 0, left - xd);
  }
}

- (void)moveToPageAtIndex:(NSInteger)pageIndex resetEdges:(BOOL)resetEdges {
  if (resetEdges) {
    _pageEdges = _pageStartEdges = UIEdgeInsetsZero;
    [self setNeedsLayout];
  } else if (pageIndex != _currentPageIndex) {
    [self adjustPageEdgesForPageAtIndex:pageIndex];
  }

  NSInteger indexDiff = pageIndex - _currentPageIndex;
  if (indexDiff) {
    if (abs(indexDiff) <= T3_OFFSCREEN_PAGES) {
      if (indexDiff > 0) {
        NSInteger edgeIndex = _currentPageIndex - T3_OFFSCREEN_PAGES;
        NSInteger newEdgeIndex = pageIndex - T3_OFFSCREEN_PAGES;
        for (int i = edgeIndex; i < newEdgeIndex; ++i) {
          [self enqueuePageAtIndex:i];
        }
      } else if (indexDiff < 0) {
        NSInteger edgeIndex = _currentPageIndex + T3_OFFSCREEN_PAGES;
        NSInteger newEdgeIndex = pageIndex + T3_OFFSCREEN_PAGES;
        for (int i = edgeIndex; i > newEdgeIndex; --i) {
          [self enqueuePageAtIndex:i];
        }
      }
    } else {
      [self enqueueAllPages];
    }

    _pageArrayIndex = [self pageIndexForItemIndex:pageIndex relativeToIndex:_currentPageIndex];
    _currentPageIndex = pageIndex;
  }
}

- (void)layoutPage {
  UIView* view = [self pageAtIndex:_currentPageIndex create:YES];
  if (view) {
    CGAffineTransform rotation = [self transformForOrientation:_orientation];
    CGPoint offset = [self offsetForOrientation:_pageEdges.left y:_pageEdges.top];
    CGRect frame = [self frameOfPageAtIndex:_currentPageIndex];
    
    if (self.zoomed) {
      CGFloat stretchedWidth = -_pageEdges.left + self.pageWidth + _pageEdges.right;
      CGFloat zoom = stretchedWidth / self.pageWidth;
      
      view.transform = [self rotateTransform:CGAffineTransformScale(
        CGAffineTransformMakeTranslation(offset.x, offset.y), zoom, zoom)];
      view.frame = CGRectMake(offset.x + (frame.origin.x*zoom), offset.y + (frame.origin.y*zoom),
        frame.size.width*zoom, frame.size.height*zoom);
    } else {
      view.transform = rotation;
      view.frame = CGRectMake(offset.x + frame.origin.x, offset.y + frame.origin.y,
        frame.size.width, frame.size.height);
    }
  }
}

- (void)layoutAdjacentPages {
  BOOL flipped = self.flipped;
  BOOL pinched = self.pinched;
  CGAffineTransform rotation = [self transformForOrientation:_orientation];

  NSInteger minPageIndex = _currentPageIndex - T3_OFFSCREEN_PAGES;
  NSInteger maxPageIndex = _currentPageIndex + T3_OFFSCREEN_PAGES;

  for (NSInteger i = _currentPageIndex - 1; i >= 0 && i >= minPageIndex; --i) {
    UIView* view = [self pageAtIndex:i create:YES];
    if (view) {
      NSInteger relativeIndex = -(_currentPageIndex - i);
      CGFloat x = flipped
        ? ((self.pageWidth + _pageSpacing) * -relativeIndex) + _pageEdges.right
        : ((self.pageWidth + _pageSpacing) * relativeIndex) + _pageEdges.left;
      CGPoint offset = [self offsetForOrientation:x y:0];
      CGRect frame = [self frameOfPageAtIndex:i];

      view.transform = rotation;
      view.frame = CGRectMake(offset.x + frame.origin.x, offset.y + frame.origin.y,
        frame.size.width, frame.size.height);
      view.hidden = pinched;
    }
  }

  NSInteger pageCount = [_dataSource numberOfItemsInScrollView:self];
  for (NSInteger i = _currentPageIndex + 1; i < pageCount && i <= maxPageIndex; ++i) {
    UIView* view = [self pageAtIndex:i create:YES];
    if (view) {
      NSInteger relativeIndex = i - _currentPageIndex;
      CGFloat x = flipped
        ? ((self.pageWidth + _pageSpacing) * -relativeIndex) + _pageEdges.left
        : ((self.pageWidth + _pageSpacing) * relativeIndex) + _pageEdges.right;
      CGPoint offset = [self offsetForOrientation:x y:0];
      CGRect frame = [self frameOfPageAtIndex:i];

      view.transform = rotation;
      view.frame = CGRectMake(offset.x + frame.origin.x, offset.y + frame.origin.y,
        frame.size.width, frame.size.height);
      view.hidden = pinched;
    }
  }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
  _orientation = orientation;
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:T3_TRANSITION_DURATION];
    [self layoutPage];
    [UIView commitAnimations];
  } else {
    [self setNeedsLayout];
  }
}

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

- (UIEdgeInsets)squareTouchEdges:(UIEdgeInsets)edges {
  if (_touchCount == 1) {
    return edges;
  } else {
    CGFloat width = edges.right - edges.left;
    CGFloat height = edges.bottom - edges.top;
    CGFloat d = sqrt((width*width) + (height*height));
    CGFloat midX = edges.left + (width/2);
    CGFloat midY = edges.top + (height/2);

    return UIEdgeInsetsMake(midY - d/2, midX - d/2, midY + d/2, midX + d/2);
  }
}

- (UIEdgeInsets)touchEdgesForPoint:(CGPoint)point {
  return [self stretchTouchEdges:UIEdgeInsetsZero toPoint:point];
}

- (UIEdgeInsets)zoomPageEdgesTo:(CGPoint)point {
  UIEdgeInsets edges = _pageEdges;

  CGFloat zoom = T3TapZoom * self.pageWidth;
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

  return edges;
}

- (UIEdgeInsets)reversePageEdges {
  UIEdgeInsets edges = _pageEdges;

  edges.left = -edges.left;
  edges.right = -edges.right;
  edges.top = -edges.top;
  edges.bottom = -edges.bottom;

  return edges;
}

- (UIEdgeInsets)constrainEdges:(UIEdgeInsets)edges toWidth:(CGFloat)constrainedWidth {
  CGFloat constrainedHeight = constrainedWidth * (self.pageHeight/self.pageWidth);

  CGFloat height = -edges.top + self.pageHeight + edges.bottom;
  CGFloat width = -edges.left + self.pageWidth + edges.right;

  CGFloat xd = constrainedWidth - width;
  CGFloat yd = constrainedHeight - height;
  
  return UIEdgeInsetsMake(edges.top - yd/2, edges.left - xd/2,
    edges.bottom + yd/2, edges.right + xd/2);
}

- (UIEdgeInsets)resistPageEdges:(UIEdgeInsets)edges {  
  CGFloat newWidth = -edges.left + self.pageWidth + edges.right;
  CGFloat minWidth = self.pageWidth * T3MinimumZoom;
  CGFloat maxWidth = self.pageWidth * T3MaximumZoom;
  if (newWidth < minWidth) {
    edges = [self constrainEdges:edges toWidth:minWidth];
  } else if (newWidth > maxWidth) {
    edges = [self constrainEdges:edges toWidth:maxWidth];
  }

//  if (-left + right < 0) {
//    T3LOG(@"LT");
//    left *= T3DragResistance;
//    right *= T3DragResistance;
//    top *= T3DragResistance;
//    bottom *= T3DragResistance;
//  } else {
//    if (_touchCount == 2 || self.zoomed) {
//      if (-top + bottom < 0) {
//        T3LOG(@"TA");
//        top *= T3DragResistance2;
//        bottom *= T3DragResistance2;
//      } else if (top > 0) {
//        T3LOG(@"TB");
//        top *= T3DragResistance;
//        bottom = _pageEdges.bottom + (top - _pageEdges.top);
//      } else if (bottom < 0) {
//        T3LOG(@"TC %f, %f, %f, %f", top, bottom, edges.top, edges.bottom);
//        bottom *= T3DragResistance;
//        top = _pageEdges.top + (bottom - _pageEdges.bottom);
//      }
//    }
//
//    if (-left + right < 0) {
//      T3LOG(@"LA");
//      left *= T3DragResistance2;
//      right *= T3DragResistance2;
//    } else if (left > 0 && ([self isFirstPage] || self.zoomed)) {
//      T3LOG(@"LB");
//      left *= T3DragResistance;
//      right = _pageEdges.right + (left - _pageEdges.left);
//    } else if (right < 0 && ([self isLastPage] || self.zoomed)) {
//      T3LOG(@"LC");
//      right *= T3DragResistance;
//      left = _pageEdges.left + (right - _pageEdges.right);
//    }
//  }
//
//  if (-left + right < 0) {
//    T3LOG(@"LT");
//    left *= T3DragResistance2;
//    right *= T3DragResistance2;
//    top *= T3DragResistance2;
//    bottom *= T3DragResistance2;
//  }

  return edges;
}

- (UIEdgeInsets)pageEdgesForAnimation {
  CGFloat left = 0, right = 0, top = 0, bottom = 0;
  if (self.pinched) {
    left = -_pageEdges.left;
    right = -_pageEdges.right;
    top = -_pageEdges.top;
    bottom = -_pageEdges.bottom;
  } else if (self.flicked) {
    if (_pageEdges.left < 0) {
      if (abs(_pageStartEdges.left) >= abs(_pageEdges.right)) {
        left = right = -((self.pageWidth + _pageSpacing) + _pageEdges.right);
      } else {
        left = right = -((self.pageWidth + _pageSpacing) + _pageEdges.left);
      }
    } else {
      if (abs(_pageEdges.left) >= abs(_pageEdges.right)) {
        left = right = ((self.pageWidth + _pageSpacing) - _pageEdges.right);
      } else {
        left = right = ((self.pageWidth + _pageSpacing) - _pageEdges.left);
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

- (void)acquireTouch:(UITouch*)touch {
  if (!_touch1) {
    _touch1 = touch;
    ++_touchCount;
  } else if (!_touch2) {
    _touch2 = touch;
    ++_touchCount;
  }
}

- (UITouch*)removeTouch:(UITouch*)touch {
  if (touch == _touch1) {
    _touch1 = nil;
    --_touchCount;
    return _touch2;
  } else if (touch == _touch2) {
    _touch2 = nil;
    --_touchCount;
    return _touch1;
  } else {
    return nil;
  }
}

- (void)stopAnimation:(BOOL)resetEdges {
  if (_animationTimer) {
    [_animationTimer invalidate];
    _animationTimer = nil;
    [_animationStartTime release];
    _animationStartTime = nil;

    NSInteger realIndex = [self realPageIndex];
    if (realIndex != _currentPageIndex || self.pinched) {
      [self moveToPageAtIndex:realIndex resetEdges:resetEdges];
    }
  }
}

- (CGFloat)tween:(NSTimeInterval)t b:(NSTimeInterval)b c:(NSTimeInterval)c d:(NSTimeInterval)d {
	return c*((t=t/d-1)*t*t + 1) + b;
}

- (void)animator {
  NSTimeInterval kt = -[_animationStartTime timeIntervalSinceNow];
  CGFloat pct = kt ? [self tween:kt b:0 c:kt d:_animationDuration]/kt : 0;
  
  _pageEdges.left = _pageStartEdges.left + _animateEdges.left * pct;
  _pageEdges.right = _pageStartEdges.right + _animateEdges.right * pct;
  _pageEdges.top = _pageStartEdges.top + _animateEdges.top * pct;
  _pageEdges.bottom = _pageStartEdges.bottom + _animateEdges.bottom * pct;
  //T3LOGEDGES(_pageEdges);

  [self setNeedsLayout];

  if (pct >= 1.0) {
    [self stopAnimation:YES];
  }
}

- (void)startAnimationTo:(UIEdgeInsets)edges duration:(NSTimeInterval)duration {
  if (!_animationTimer) {
    _pageStartEdges = _pageEdges;
    _animateEdges = edges;
    _animationDuration = duration;
    _animationStartTime = [[NSDate date] retain];
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self
      selector:@selector(animator) userInfo:nil repeats:YES];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [self layoutPage];
  [self layoutAdjacentPages];
}

- (void)didMoveToSuperview {
  if (!self.superview) {
    [self stopAnimation:YES];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_touchCount < 2) {
    [self stopAnimation:NO];
    
    for (UITouch* touch in touches) {
      [self acquireTouch:touch];

      if (_scrollEnabled) {
        if (_touchCount == 1) {
          CGPoint pt = [self touchLocation:touch];
          _touchStartEdges = _touchEdges = [self touchEdgesForPoint:pt];
          _pageStartEdges = _pageEdges;

          if (touch.tapCount == 2) {
            if (self.zoomed) {
              [self startAnimationTo:[self reversePageEdges] duration:T3FlickInterval];
            } else {
              [self startAnimationTo:[self zoomPageEdgesTo:pt] duration:T3FlickInterval];
            }
          }
        } else if (_touchCount == 2) {
          CGPoint pt = [self touchLocation:touch];
          _touchEdges = [self stretchTouchEdges:_touchEdges toPoint:pt];
          _touchStartEdges = [self squareTouchEdges:_touchEdges];
          _pageStartEdges = _pageEdges;
        }
      }
    }
  }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
  if (_scrollEnabled && _touchCount && !_animationTimer) {
    _touchEdges = UIEdgeInsetsZero;
    for (UITouch* touch in [event allTouches]) {
      if (touch == _touch1 || touch == _touch2) {
        // CGPoint pt = [self touchLocation:touch];
        // T3LOG(@"MOVE %d/%d %f x %f", i, [[event allTouches] count], pt.x, pt.y);
        _touchEdges = [self stretchTouchEdges:_touchEdges toPoint:[self touchLocation:touch]];
      }
    }
    
    UIEdgeInsets edges = [self squareTouchEdges:_touchEdges];
    
    CGFloat left = _pageStartEdges.left + (edges.left - _touchStartEdges.left);
    CGFloat right = _pageStartEdges.right + (edges.right - _touchStartEdges.right);
    CGFloat top = _pageEdges.top;
    CGFloat bottom = _pageEdges.bottom;
    if (_touchCount == 2 || self.zoomed) {
      CGFloat r = self.pageHeight / self.pageWidth;
      top = _pageStartEdges.top + (edges.top - _touchStartEdges.top) * r;
      bottom = _pageStartEdges.bottom + (edges.bottom - _touchStartEdges.bottom) * r;
    }
      
    _pageEdges = [self resistPageEdges:UIEdgeInsetsMake(top, left, bottom, right)];
    //T3LOGEDGES(_pageEdges);
    
    [self setNeedsLayout];
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch* touch in touches) {
    [self removeTouch:touch];
  }
  
  if (!_touchCount) {
    [self stopAnimation:YES];

    _pageEdges = UIEdgeInsetsZero;
    [self setNeedsLayout];
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  for (UITouch* touch in touches) {
    if (touch == _touch1 || touch == _touch2) {
      UITouch* remainingTouch = [self removeTouch:touch];

      if (_touchCount == 1) {
        CGPoint point = [self touchLocation:remainingTouch];
        _touchEdges = _touchStartEdges = [self touchEdgesForPoint:point];
        _pageStartEdges = _pageEdges;
      }
      
      if (self.pinched || (_touchCount == 0 && self.pulled)) {
        UIEdgeInsets edges = [self pageEdgesForAnimation];
        NSTimeInterval dur = self.flicked ? T3FlickInterval : T3BounceInterval;
        [self startAnimationTo:edges duration:dur];
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
  UIInterfaceOrientation orientation = T3DeviceOrientation();
  if (_rotateEnabled
      && (![_delegate respondsToSelector:@selector(scrollView:shouldAutorotateToInterfaceOrientation:)]
      || [_delegate scrollView:self shouldAutorotateToInterfaceOrientation:orientation])) {
    if ([self supportsOrientation:orientation]) {
      self.orientation = orientation;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataSource:(id<T3ScrollViewDataSource>)dataSource {
  _dataSource = dataSource;
  [self rebuild];
}

- (void)setCurrentPageIndex:(NSInteger)index {
  [self moveToPageAtIndex:index resetEdges:YES];
}

- (UIView*)currentPageView {
  return [self pageAtIndex:_currentPageIndex create:YES];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation {
  [self setOrientation:orientation animated:YES];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
  if (orientation != _orientation) {
    [self rotateToOrientation:orientation animated:animated];
  }
}

- (UIView*)dequeueReusablePage {
  if (_pageViewQueue.count) {
    UIView* pageView = [[_pageViewQueue.lastObject retain] autorelease];
    [_pageViewQueue removeLastObject];
    return pageView;
  } else {
    return nil;
  }
}

- (void)rebuild {
  if (_dataSource) {
    [self enqueueAllPages];
    [self setNeedsLayout];
  }
}

@end
