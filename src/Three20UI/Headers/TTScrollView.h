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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TTScrollViewDelegate;
@protocol TTScrollViewDataSource;

@interface TTScrollView : UIView {
  NSInteger       _centerPageIndex;
  NSInteger       _visiblePageIndex;
  BOOL            _scrollEnabled;
  BOOL            _zoomEnabled;
  BOOL            _rotateEnabled;
  CGFloat         _pageSpacing;
  NSTimeInterval  _holdsAfterTouchingForInterval;

  UIInterfaceOrientation  _orientation;

  id<TTScrollViewDelegate>    _delegate;
  id<TTScrollViewDataSource>  _dataSource;

  NSMutableArray* _pages;
  NSMutableArray* _pageQueue;
  NSInteger       _maxPages;
  NSInteger       _pageArrayIndex;
  NSTimer*        _tapTimer;
  NSTimer*        _holdingTimer;
  NSTimer*        _animationTimer;
  NSDate*         _animationStartTime;
  NSTimeInterval  _animationDuration;
  UIEdgeInsets    _animateEdges;

  // Speed for Inertia.
  CGPoint      _inertiaSpeed;
  CGPoint      _renewPosition;

  // A floating-point value that specifies the maximum scale factor that can be applied to
  // the scroll view's content.
  CGFloat _maximumZoomScale;
  CGFloat _zoomScale;

  // Middle point bewteen fingers, is used to zoom using fingers positon and not the center
  // of the image.
  CGPoint centerOfFingers;

  // Distance between fingers, used to calculate zoom scale and zoom speed rate.
  CGFloat actualDistanceBetweenFingers;
  CGFloat distanceBetweenFingers;

  // A floating-point value that determines the rate of deceleration after the user lifts
  // their finger.
  CGFloat _decelerationRate;

  // The offset of the page edges from the edge of the screen.
  UIEdgeInsets    _pageEdges;

  // At the beginning of an animation, the page edges are cached within this member.
  UIEdgeInsets    _pageStartEdges;

  UIEdgeInsets    _touchEdges;
  UIEdgeInsets    _touchStartEdges;
  NSUInteger      _touchCount;
  CGFloat         _overshoot;

  // Scroll animation.
  // Set the engine to animate the next relayout.
  BOOL _nextLayoutAnimated;
  NSTimeInterval _centerPageAnimationDuration;

  // The first touch in this view.
  UITouch*        _touch1;

  // The second touch in this view.
  UITouch*        _touch2;

  BOOL            _dragging;
  BOOL            _decelerating;
  BOOL            _zooming;
  BOOL            _executingZoomGesture;
  BOOL            _holding;
}

/**
 * Retrieve or set the current page index.
 * If you inform anew value for this page, the Scroll View will
 * load this page on the center of the view.
 * This operatin is not animated, you should use <tt>setCenterPageIndex:animated:</tt>
 * if you want to control the animation.
 */
@property (nonatomic) NSInteger centerPageIndex;

/**
 * Set the duration for the animation performed by the <tt>setCenterPageIndex:animated:</tt>
 * method.
 *
 * @default Is the value setted on the <tt>TT_TRANSITION_DURATION</tt> constant.
 */
@property (assign) NSTimeInterval centerPageAnimationDuration;

/**
 * Whether or not the current page is zoomed.
 */
@property (nonatomic, readonly) BOOL zoomed;

/**
 * A Boolean value that indicates whether the content view is currently zooming in or
 * out. (read-only)
 *
 * The value of this property is YES if user is making a zoom gesture, otherwise it is NO
 */
@property (nonatomic, readonly) BOOL zooming;

/**
 * A Boolean value that indicates whether the user is scrolling the
 * view with his finger. If the scroll is scrolling by animation this
 * value is NO. (read-only)
 */
@property (readonly) BOOL isDragging;

/**
 * The scroller is performing an "hold" action.
 */
@property (nonatomic, readonly) BOOL holding;

/**
 * Returns whether the content is moving in the scroll view after the user lifted their
 * finger. (read-only)
 */
@property (nonatomic,readonly,getter=isDecelerating) BOOL decelerating;

/**
 * A Boolean value that determines whether scrolling is enabled.
 *
 * @default YES
 */
@property (nonatomic) BOOL scrollEnabled;

/*
 * A Boolean value that determines whether zooming is enabled.
 *
 * @default YES
 */
@property (nonatomic) BOOL zoomEnabled;

/**
 * A Boolean value that determines whether rotation is enabled.
 *
 * @default YES
 */
@property (nonatomic) BOOL rotateEnabled;

/**
 * A <tt>CGFloat</tt> value that determines the gap between the pages.
 *
 * @default 40
 */
@property (nonatomic) CGFloat pageSpacing;

@property (nonatomic)           UIInterfaceOrientation  orientation;
@property (nonatomic, readonly) NSInteger               numberOfPages;
@property (nonatomic, readonly) UIView*                 centerPage;

/**
 * The number of seconds to wait before initiating the "hold" action.
 *
 * @default 0
 */
@property (nonatomic) NSTimeInterval holdsAfterTouchingForInterval;

/**
 * A floating-point value that determines the rate of deceleration after the user lifts
 * their finger.
 *
 * @default 0.9
 */
@property CGFloat decelerationRate;

/**
 * A floating-point value that specifies the current scale factor applied to the scroll
 * view's content.
 *
 * The scale is animated by Default, use setZoomScale:animated: to control when is
 * animated or not.
 *
 * @default 1.0
 */
@property (nonatomic,assign) CGFloat zoomScale;

/**
 * A floating-point value that specifies the maximum scale factor that
 * can be applied to the scroll view's content.
 *
 * @default 4.0
 */
@property (nonatomic) CGFloat maximumZoomScale;

@property (nonatomic, assign) id<TTScrollViewDelegate>    delegate;
@property (nonatomic, assign) id<TTScrollViewDataSource>  dataSource;

/**
 * A dictionary of visible pages keyed by the index of the page.
 */
@property (nonatomic, readonly) NSDictionary* visiblePages;

- (void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 * A floating-point value that specifies the current zoom scale.
 *
 * YES to animate the transition to the new scale, NO to make the transition immediate.
 */
- (void)setZoomScale:(CGFloat)newScale animated:(BOOL)animated;

/**
 * A floating-point value that specifies the current zoom scale.
 *
 * Specify one point to scale centering to him.
 *
 * YES to animate the transition to the new scale, NO to make the transition immediate.
 */
- (void)setZoomScale:(CGFloat)newScale withPoint:(CGPoint)withPoint animated:(BOOL)animated;

/**
 * Gets a previously created page view that has been moved off screen and recycled.
 */
- (UIView*)dequeueReusablePage;

- (void)reloadData;

- (UIView*)pageAtIndex:(NSInteger)pageIndex;

- (void)zoomToFit;

- (void)zoomToDistance:(CGFloat)distance;

/**
 * Set the current center page and optionally animate the transition.
 * <b>Only animate if the distance between the actual page and the informed
 * is one. Example: If is one page 1 and you inform page 3, will not animate.</b>
 */
- (void)setCenterPageIndex:(NSInteger)centerPageIndex animated:(BOOL)animated;

/**
 * Cancels any active touches and resets everything to an untouched state.
 */
- (void)cancelTouches;

@end
