#import "Three20/TTLoadable.h"

typedef enum {
  TTModelStateEmpty = 0,
  TTModelStateLoading = 1,
  TTModelStateLoadingMore = 2,
  TTModelStateRefreshing = 4,
  TTModelStateLoaded = 8,
  TTModelStateLoadedError = 16,
  TTModelLoadingStates = (TTModelStateLoading|TTModelStateLoadingMore|TTModelStateRefreshing),
  TTModelLoadedStates = (TTModelStateLoaded|TTModelStateLoadedError),
} TTModelState;

@interface TTViewController : UIViewController <TTLoadableDelegate> {
  NSDictionary* _frozenState;
  TTModelState _modelState;
  NSError* _modelError;
  
  UIBarStyle _navigationBarStyle;
  UIColor* _navigationBarTintColor;
  UIStatusBarStyle _statusBarStyle;

  BOOL _isModelInvalid;
  BOOL _isValidatingModel;
  BOOL _isViewInvalid;
  BOOL _isLoadingViewInvalid;
  BOOL _isLoadedViewInvalid;
  BOOL _isValidatingView;
  BOOL _isViewAppearing;
  BOOL _hasViewAppeared;
  BOOL _autoresizesForKeyboard;
}

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
 * Indicates the state of the view with regards to the content it displays.
 *
 * Changing modelState will invalidate relevant portions of the view, which may result in
 * modelDidChangeLoadingState or modelDidChangeLoadedState to be called to update the aspects of the view that
 * have changed.
 */ 
@property(nonatomic) TTModelState modelState;

/**
 * An error that occurred while trying to load content.
 */ 
@property(nonatomic, retain) NSError* modelError;

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
 * Reloads the model.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)reload;

/**
 * Reloads the model if it has become out-of-date.
 */
- (void)reloadIfNeeded;

/**
 * Invalidates the model and schedules it for an update at the next appropriate time.
 *
 * When something related to your model has significantly changed, invalidateModel is a good way
 * to efficiently update the model to reflect those changes.  If your view is not visible,
 * you probably don't want to waste cycles updating it to reflect the data changes.  By 
 * invalidating the model instead of updating it immediately, you can delay the updating
 * until it is necessary.
 */
- (void)invalidateModel;

/**
 * Updates the model if it is invalid.
 */
- (void)validateModel;

/**
 * Indicates that the model has changed and schedules the view to be updated to reflect it.
 *
 * Invalidation allow you to change the state of the view without actually changing
 * the view.  This is necessary because low memory conditions can cause views to be destroyed
 * and re-created behind your back, so you need to maintain important state without them.
 */
- (void)invalidateView;

/** 
 * Updates the view to the latest model.
 *
 * If the model is invalid, the model will be updated before update the view.
 */
- (void)validateView;

/** 
 * Updates the model to the latest data.
 *
 * Updating the model will usually have the side-effect of calling invalidateView so that the
 * view can reflect the changes to the model.
 */
- (void)updateModel;

/**
 * Updates the view after the model has changed.
 *
 * You should not call this directly.  Call validate instead so that you don't waste
 * time updating if the model is not invalid. Subclasses should implement this method
 * and check modelState to decide how to update the view.
 */
- (void)modelDidChange;

/**
 * Updates aspects of the view which reflect loading activity.
 */
- (void)modelDidChangeLoadingState;

/**
 * Updates aspects of the view which reflect data that has been loaded.
 */
- (void)modelDidChangeLoadedState;

/**
 * Sent to the controller before the keyboard slides in.
 */
- (void)keyboardWillAppear:(BOOL)animated;

/**
 * Sent to the controller before the keyboard slides out.
 */
- (void)keyboardWillDisappear:(BOOL)animated;

@end
