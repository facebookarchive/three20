#import "Three20/TTViewController.h"
#import "Three20/TTModel.h"

typedef enum {
  TTModelStateEmpty = 0,
  TTModelStateLoading = 1,
  TTModelStateLoadingMore = 2,
  TTModelStateReloading = 4,
  TTModelStateLoaded = 8,
  TTModelStateLoadedError = 16,
  TTModelLoadingStates = (TTModelStateLoading|TTModelStateLoadingMore|TTModelStateReloading),
  TTModelLoadedStates = (TTModelStateLoaded|TTModelStateLoadedError),
} TTModelState;

/**
 * A view controller that manages a model in addition to a view.
 */
@interface TTModelViewController : TTViewController <TTModelDelegate> {
  id<TTModel> _model;
  TTModelState _modelState;
  NSError* _modelError;
  
  BOOL _isViewInvalid;
  BOOL _isLoadingViewInvalid;
  BOOL _isLoadedViewInvalid;
  BOOL _isValidatingView;
}

@property(nonatomic,retain) id<TTModel> model;

/**
 * Indicates the state of the view with regards to the content it displays.
 *
 * Changing modelState will invalidate relevant portions of the view, which may result in
 * modelDidChangeLoadingState or modelDidChangeLoadedState to be called to update the aspects
 * of the view that have changed.
 */ 
@property(nonatomic) TTModelState modelState;

/**
 * An error that occurred while trying to load content.
 */ 
@property(nonatomic, retain) NSError* modelError;

/**
 * Creates the model that the controller manages.
 */
- (void)loadModel;

/**
 * 
 */
- (void)modelDidLoad;

/**
 * 
 */
- (void)modelDidUnload;

/**
 * 
 */
- (BOOL)isModelLoaded;

/**
 * Indicates that data should be loaded from the model.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (BOOL)shouldLoad;

/**
 * Indicates that data should be reloaded from the model.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (BOOL)shouldReload;

/**
 * Indicates that more data should be loaded from the model.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (BOOL)shouldLoadMore;

/**
 * Reloads data from the model.
 */
- (void)reload;

/**
 * Reloads data from the model if it has become out of date.
 */
- (void)reloadIfNeeded;

/**
 * Refreshes the model state and loads new data if necessary.
 */
- (void)refresh;

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
 * Informs the controller that its model is about to appear for the first time.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (void)modelWillAppear;

/**
 * Informs the controller that its model's state has changed.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (void)modelDidChangeState;

/**
 * Informs the controller that its model's loading state has changed.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (void)modelDidChangeLoadingState;

/**
 * Informs the controller that its model's loaded state has changed.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (void)modelDidChangeLoadedState;

@end
