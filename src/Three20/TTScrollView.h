/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTGlobal.h"

@protocol TTScrollViewDelegate;
@protocol TTScrollViewDataSource;

@interface TTScrollView : UIView {
  id<TTScrollViewDelegate> _delegate;
  id<TTScrollViewDataSource> _dataSource;
  NSInteger _centerPageIndex;
  NSInteger _visiblePageIndex;
  BOOL _scrollEnabled;
  BOOL _zoomEnabled;
  BOOL _rotateEnabled;
  CGFloat _pageSpacing;
  UIInterfaceOrientation _orientation;
  NSTimeInterval _holdsAfterTouchingForInterval;
  
  NSMutableArray* _pages;
  NSMutableArray* _pageQueue;
  NSInteger _maxPages;
  NSInteger _pageArrayIndex;
  NSTimer* _tapTimer;
  NSTimer* _holdingTimer;
  NSTimer* _animationTimer;
  NSDate* _animationStartTime;
  NSTimeInterval _animationDuration;
  UIEdgeInsets _animateEdges;
  UIEdgeInsets _pageEdges;
  UIEdgeInsets _pageStartEdges;
  UIEdgeInsets _touchEdges;
  UIEdgeInsets _touchStartEdges;
  NSUInteger _touchCount;
  CGFloat _overshoot;
  UITouch* _touch1;
  UITouch* _touch2;
  BOOL _dragging;
  BOOL _zooming;
  BOOL _holding;
}

/**
 *
 */
@property(nonatomic,assign) id<TTScrollViewDelegate> delegate;

/**
 *
 */
@property(nonatomic,assign) id<TTScrollViewDataSource> dataSource;

/**
 *
 */
@property(nonatomic) NSInteger centerPageIndex;

/**
 *
 */
@property(nonatomic,readonly) BOOL zoomed;

/**
 *
 */
@property(nonatomic,readonly) BOOL holding;

/**
 *
 */
@property(nonatomic) BOOL scrollEnabled;

/**
 *
 */
@property(nonatomic) BOOL zoomEnabled;

/**
 *
 */
@property(nonatomic) BOOL rotateEnabled;

/**
 *
 */
@property(nonatomic) CGFloat pageSpacing;

/**
 *
 */
@property(nonatomic) UIInterfaceOrientation orientation;

/**
 *
 */
@property(nonatomic) NSTimeInterval holdsAfterTouchingForInterval;

/**
 *
 */
@property(nonatomic,readonly) NSInteger numberOfPages;

/**
 *
 */
@property(nonatomic,readonly) UIView* centerPage;

/**
 * A dictionary of visible pages keyed by the index of the page.
 */
@property(nonatomic,readonly) NSDictionary* visiblePages;

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 * Gets a previously created page view that has been moved off screen and recycled.
 */
- (UIView*)dequeueReusablePage;

/**
 *
 */
- (void)reloadData;

/**
 *
 */
- (UIView*)pageAtIndex:(NSInteger)pageIndex;

/**
 *
 */
- (void)zoomToFit;

/**
 *
 */
- (void)zoomToDistance:(CGFloat)distance;

/**
 * Cancels any active touches and resets everything to an untouched state.
 */
- (void)cancelTouches;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTScrollViewDelegate <NSObject>

/**
 *
 */
- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

/**
 *
 */
- (void)scrollViewWillRotate:(TTScrollView*)scrollView
        toOrientation:(UIInterfaceOrientation)orientation;

/**
 *
 */
- (void)scrollViewDidRotate:(TTScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewWillBeginDragging:(TTScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndDragging:(TTScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

/**
 *
 */
- (void)scrollViewDidEndDecelerating:(TTScrollView*)scrollView;

/**
 *
 */
- (BOOL)scrollViewShouldZoom:(TTScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidBeginZooming:(TTScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndZooming:(TTScrollView*)scrollView;

/**
 *
 */
- (void)scrollView:(TTScrollView*)scrollView touchedDown:(UITouch*)touch;

/**
 *
 */
- (void)scrollView:(TTScrollView*)scrollView touchedUpInside:(UITouch*)touch;

/**
 *
 */
- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch;

/**
 *
 */
- (void)scrollViewDidBeginHolding:(TTScrollView*)scrollView;

/**
 *
 */
- (void)scrollViewDidEndHolding:(TTScrollView*)scrollView;

@optional

- (BOOL)scrollView:(TTScrollView*)scrollView 
        shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTScrollViewDataSource <NSObject>

/**
 *
 */
- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView;

/**
 * Gets a view to display for the page at the given index.
 *
 * You do not need to position or size the view as that is done for you later.  You should
 * call dequeueReusablePage first, and only create a new view if it returns nil.
 */
- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex;

/**
 * Gets the natural size of the page. 
 *
 * The actual width and height are not as important as the ratio between width and height.
 * This is used to determine how to 
 */
- (CGSize)scrollView:(TTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex;

@end
