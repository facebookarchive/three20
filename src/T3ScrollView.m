#import "Three20/T3ScrollView.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#define T3_OFFSCREEN_PAGES 1
#define T3_MAX_PAGES ((T3_OFFSCREEN_PAGES*2) + 1)
#define T3_MIN_GLIDE_AMOUNT 1

static const CGFloat T3DefaultPageSpacing = 40.0;
static const CGFloat T3FlickThreshold = 60.0;
static const CGFloat T3DragEdgeResistance = 0.6;
static const NSInteger T3InvalidIndex = -1;
static const NSTimeInterval T3GlideTimeInterval = 0.4;
static const NSTimeInterval T3BounceTimeInterval = 0.5;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ScrollView

@synthesize delegate = _delegate, dataSource = _dataSource, scrollEnabled = _scrollEnabled,
  currentPageIndex = _currentPageIndex;


- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    
    _delegate = nil;
    _dataSource = nil;
    _pageViews = [[NSMutableArray alloc] initWithCapacity:T3_MAX_PAGES];
    _pageViewQueue = [[NSMutableArray alloc] init];
    _pageSpacing = T3DefaultPageSpacing;
    _currentPageIndex = 3;
    _pageArrayIndex = 0;
    _tracking = NO;
    _dragging = NO;
    _flicked = NO;
    _scrollEnabled = YES;
    
    for (NSInteger i = 0; i < T3_MAX_PAGES; ++i) {
      [_pageViews addObject:[NSNull null]];
    }
  }
  return self;
}

- (void)dealloc {
  [_glideTimer invalidate];
  [_glideStartTime release];
  [_pageViews release];
  [_pageViewQueue release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)pageIndexForItemIndex:(NSInteger)itemIndex {
  NSInteger indexDiff = itemIndex - _currentPageIndex;
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

- (UIView*)pageAtIndex:(NSInteger)index create:(BOOL)create {
  NSInteger arrayIndex = [self pageIndexForItemIndex:index];
  if (arrayIndex == T3InvalidIndex) {
    return nil;
  }
  
  UIView* pageView = [_pageViews objectAtIndex:arrayIndex];
  if ((NSNull*)pageView == [NSNull null]) {
    if (create) {
      pageView = [_dataSource scrollView:self pageAtIndex:index];
      [self addSubview:pageView];
      [_pageViews replaceObjectAtIndex:arrayIndex withObject:pageView];
    } else {
      return nil;
    }
  }
  
  return pageView;
}

- (UIView*)enqueuePageAtIndex:(NSInteger)index {
  NSInteger arrayIndex = [self pageIndexForItemIndex:index];
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

- (void)moveToPageAtIndex:(NSInteger)pageIndex {
  NSInteger indexDiff = pageIndex - _currentPageIndex;
  if (abs(indexDiff) <= T3_OFFSCREEN_PAGES) {
    if (indexDiff > 0) {
      NSInteger edgeIndex = _currentPageIndex - T3_OFFSCREEN_PAGES;
      NSInteger newEdgeIndex = pageIndex - T3_OFFSCREEN_PAGES;
      for (int i = edgeIndex; i < newEdgeIndex; ++i) {
        [self enqueuePageAtIndex:i];
      }
    } else {
      NSInteger edgeIndex = _currentPageIndex + T3_OFFSCREEN_PAGES;
      NSInteger newEdgeIndex = pageIndex + T3_OFFSCREEN_PAGES;
      for (int i = edgeIndex; i > newEdgeIndex; --i) {
        [self enqueuePageAtIndex:i];
      }
    }
  } else {
    for (int i = 0; i < _pageViews.count; ++i) {
      [self enqueuePageAtIndex:i];
    }
  }

  _pageArrayIndex = [self pageIndexForItemIndex:pageIndex];
  _currentPageIndex = pageIndex;
  [self setNeedsLayout];
}

- (void)layoutLTRWithOffset:(CGFloat)offset withFront:(BOOL)withFront {
  NSInteger startIndex = _currentPageIndex + (withFront ? 0 : -1);
  NSInteger minPageIndex = _currentPageIndex - T3_OFFSCREEN_PAGES;
  for (NSInteger i = startIndex; i >= 0 && i >= minPageIndex; --i) {
    UIView* view = [self pageAtIndex:i create:YES];
    if (view) {
      NSInteger relativeIndex = -(_currentPageIndex - i);
      CGFloat x = ((self.width + _pageSpacing) * relativeIndex) + offset;
      view.frame = CGRectMake(x, 0, self.width, self.height);
    }
  }
}

- (void)layoutRTLWithOffset:(CGFloat)offset withFront:(BOOL)withFront {
  NSInteger startIndex = _currentPageIndex + (withFront ? 0 : 1);
  NSInteger pageCount = [_dataSource numberOfItemsInScrollView:self];
  NSInteger maxPageIndex = _currentPageIndex + T3_OFFSCREEN_PAGES;
  for (NSInteger i = startIndex; i < pageCount && i <= maxPageIndex; ++i) {
    UIView* view = [self pageAtIndex:i create:YES];
    if (view) {
      NSInteger relativeIndex = i - _currentPageIndex;
      CGFloat x = ((self.width + _pageSpacing) * relativeIndex) + offset;
      view.frame = CGRectMake(x, 0, self.width, self.height);
    }
  }
}

- (BOOL)isFirstPage {
  return _currentPageIndex == 0;
}

- (BOOL)isLastPage {
  return _currentPageIndex+1 >= [_dataSource numberOfItemsInScrollView:self];
}

- (BOOL)draggingFromEdge {
  return (_dragLastPoint < 0 && [self isLastPage]) || (_dragLastPoint > 0 && [self isFirstPage]);
}

- (CGFloat)tween:(NSTimeInterval)t b:(NSTimeInterval)b c:(NSTimeInterval)c d:(NSTimeInterval)d {
	return c*((t=t/d-1)*t*t + 1) + b;
}

- (void)animator {
  NSTimeInterval kt = -[_glideStartTime timeIntervalSinceNow];
  NSTimeInterval dur = _flicked ? T3GlideTimeInterval : T3BounceTimeInterval;
  CGFloat pct = [self tween:kt b:0 c:kt d:dur]/kt;
  
  CGFloat x;
  if (_dragLastPoint < 0) {
    if (_flicked) {
      x = -((self.width + _pageSpacing) + _glideStartPoint) * pct;
    } else {
      x = -_glideStartPoint * pct;
    }
  } else {
    if (_flicked) {
      x = ((self.width + _pageSpacing) - _glideStartPoint) * pct;
    } else {
      x = -_glideStartPoint * pct;
    }
  }

  //NSLog(@"ANIMATE %f to %f at %f", pct, x, _glideStartPoint);
  [self layoutRTLWithOffset:_glideStartPoint + x withFront:YES];
  [self layoutLTRWithOffset:_glideStartPoint + x withFront:NO];

  if (pct >= 1.0) {
    if (_flicked) {
      [self moveToPageAtIndex:_currentPageIndex + (_dragLastPoint < 0 ? 1 : -1)];
    }

    [_glideStartTime release];
    _glideStartTime = nil;
    [_glideTimer invalidate];
    _glideTimer = nil;
    _flicked = NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [self layoutLTRWithOffset:0 withFront:YES];
  [self layoutRTLWithOffset:0 withFront:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_scrollEnabled && !_glideTimer) {
    UITouch* touch = [touches anyObject];
    for (UIView* child in self.subviews) {
      if ([child hitTest:[touch locationInView:child] withEvent:event]) {
        _dragStartPoint = _dragLastPoint = [touch locationInView:self].x;
        _dragLastMoveTime = 0;
        _tracking = YES;
      }
    }
  }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
  if (!_tracking) {
    [super touchesMoved:touches withEvent:event];
  } else if (!_glideTimer) {
    UITouch* touch = [touches anyObject];
    CGPoint newPoint = [touch locationInView:self];
    _dragLastPoint = newPoint.x - _dragStartPoint;

    if (_dragging) {
      _dragLastMoveTime = event.timestamp;
     
      CGFloat offset = [self draggingFromEdge]
        ? _dragLastPoint * (abs(_dragLastPoint) / self.width) * T3DragEdgeResistance
        : _dragLastPoint;
      [self layoutRTLWithOffset:offset withFront:YES];
      [self layoutLTRWithOffset:offset withFront:NO];
    } else {
      if (abs(_dragLastPoint) > T3_MIN_GLIDE_AMOUNT) {
        _dragging = YES;
        [self touchesMoved:touches withEvent:event];
      }
    }
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  _tracking = NO;
  if (_dragging) {
    _dragging = NO;
    _flicked = abs(_dragLastPoint) > T3FlickThreshold && ![self draggingFromEdge];
    _glideStartPoint = [self pageAtIndex:_currentPageIndex create:YES].x;
    _glideStartTime = [[NSDate date] retain];
    _glideTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self
      selector:@selector(animator) userInfo:nil repeats:YES];
  } else {
    [super touchesEnded:touches withEvent:event];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setCurrentPageIndex:(NSInteger)index {
  [self moveToPageAtIndex:index];
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

@end
