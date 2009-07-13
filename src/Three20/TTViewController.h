#import "Three20/TTGlobal.h"

typedef enum {
  TTViewEmpty = 0,
  TTViewLoading = 1,
  TTViewLoadingMore = 2,
  TTViewRefreshing = 4,
  TTViewLoaded = 8,
  TTViewLoadedError = 16,
  TTViewLoadingStates = (TTViewLoading|TTViewLoadingMore|TTViewRefreshing),
  TTViewLoadedStates = (TTViewLoaded|TTViewLoadedError),
} TTViewState;

@interface TTViewController : UIViewController {
  NSDictionary* _frozenState;
  TTViewState _viewState;
  NSError* _contentError;
  
  UIBarStyle _navigationBarStyle;
  UIColor* _navigationBarTintColor;
  UIStatusBarStyle _statusBarStyle;

  BOOL _invalidView;
  BOOL _invalidViewLoading;
  BOOL _invalidViewData;
  BOOL _validating;
  BOOL _isViewAppearing;
  BOOL _hasViewAppeared;
  BOOL _autoresizesForKeyboard;
}

/**
 * Indicates the state of the view with regards to the content it displays.
 *
 * Changing viewState will invalidate related portions of the view, which may result in
 * updateLoadingView or updateLoadedView to be called to update the aspects of the view that
 * have changed.
 */ 
@property(nonatomic) TTViewState viewState;

/**
 * An error that occurred while trying to load content.
 */ 
@property(nonatomic, retain) NSError* contentError;

/**
 * The style of the navigation bar when this controller is pushed onto a navigation controller.
 */
@property(nonatomic) UIBarStyle navigationBarStyle;

/**
 * The color of the navigation bar when this controller is pushed onto a navigation controller.
 */
@property(nonatomic,retain) UIColor* navigationBarTintColor;

/**
 * The style of the status bar when this controller is isViewAppearing.
 */
@property(nonatomic) UIStatusBarStyle statusBarStyle;

/**
 * The view has appeared at least once.
 */
@property(nonatomic,readonly) BOOL hasViewAppeared;

/**
 * The view is currently visible.
 */
@property(nonatomic,readonly) BOOL isViewAppearing;

/**
 * Determines if the view will be resized automatically to fit the keyboard.
 */
@property(nonatomic) BOOL autoresizesForKeyboard;

/**
 * Reloads content from external sources.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)reloadContent;

/**
 * Reloads content if it has become out-of-date.
 *
 * When content that has already loaded becomes out of date for any reason, here is the
 * place to refresh it just before it becomes visible.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)refreshContent;

/**
 * Invalidates the view and schedules it to be updated as soon as possible.
 *
 * Invalidation allow you to change the state of the view without actually changing
 * the view.  This is necessary because low memory conditions can cause views to be destroyed
 * and re-created behind your back, so you need to maintain important state without them.
 */
- (void)invalidateView;

/**
 * Updates all invalid aspects of the view.
 */
- (void)validateView;

/**
 * Called to update the view after it has been invalidated.
 *
 * Override this function and check viewState to decide how to update the view.
 *
 * This is meant to be implemented by subclasses - the default will update the view to indicate
 * activity, errors, and lack of content.
 */
- (void)updateView;

/**
 *
 */
- (void)updateLoadingView;

/**
 *
 */
- (void)updateLoadedView;

/**
 * Sent to the controller before the keyboard slides in.
 */
- (void)keyboardWillAppear:(BOOL)animated;

/**
 * Sent to the controller before the keyboard slides out.
 */
- (void)keyboardWillDisappear:(BOOL)animated;

@end
