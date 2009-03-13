#import "Three20/TTGlobal.h"

typedef enum {
  TTViewEmpty = 0,
  TTViewNotLoading = 1,
  TTViewLoading = 2,
  TTViewLoadingMore = 4,
  TTViewRefreshing = 8,
  TTViewLoadingStates = (TTViewNotLoading|TTViewLoading|TTViewLoadingMore|TTViewRefreshing),
  TTViewDataLoaded = 16,
  TTViewDataLoadedError = 32,
  TTViewDataStates = (TTViewDataLoaded|TTViewDataLoadedError),
} TTViewState;

@protocol TTPersistable;

@interface TTViewController : UIViewController {
  NSDictionary* _frozenState;
  TTViewState _viewState;
  NSError* _contentError;
  
  UINavigationBar* _previousBar;
  UIBarStyle _previousBarStyle;
  UIColor* _previousBarTintColor;
  UIStatusBarStyle _previousStatusBarStyle;

  BOOL _invalidContent;
  BOOL _invalidView;
  BOOL _invalidViewLoading;
  BOOL _invalidViewData;
  BOOL _validating;
  BOOL _appearing;
  BOOL _appeared;
  BOOL _unloaded;
  BOOL _autoresizesForKeyboard;
}

/**
 * The primary object behind the view.
 */
@property(nonatomic,readonly) id<TTPersistable> viewObject;

/**
 * A description of the kind of view to be presented for viewObject when the view is populated.
 */
@property(nonatomic,readonly) NSString* viewType;

/**
 * A temporary holding place for persisted view state waiting to be restored.
 */
@property(nonatomic,retain) NSDictionary* frozenState;

/**
 * Indicates the state of the view with regards to the content it displays.
 */ 
@property(nonatomic,readonly) TTViewState viewState;

/**
 * An error that occurred while trying to load content.
 */ 
@property(nonatomic, retain) NSError* contentError;

/**
 * The view has appeared at least once.
 */
@property(nonatomic,readonly) BOOL appeared;

/**
 * The view is currently visible.
 */
@property(nonatomic,readonly) BOOL appearing;

/**
 * Determines if the view will be resized automatically to fit the keyboard.
 */
@property(nonatomic) BOOL autoresizesForKeyboard;

/**
 * Update the view with a new primary object.
 *
 * @param object The primary object to display.
 * @param name A description that hints at how to display the object.
 * @param state A dictionary of attributes persisted in a previous life.
 */
- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state;

/**
 * Persist attributes of the view to a dictionary that can be restored later.
 */
- (void)persistView:(NSMutableDictionary*)state;

/**
 * Restore attributes of the view from an earlier call to persistView.
 */
- (void)restoreView:(NSDictionary*)state;

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
 * Invalidates a particular aspect of the view.
 */
- (void)invalidateViewState:(TTViewState)state;

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
- (void)updateDataView;

/**
 * Destroys all views prior to the controller itself being destroyed or going into hibernation
 * (due to a low memory warning).
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)unloadView;

/**
 * Sent to the controller before the keyboard slides in.
 */
- (void)keyboardWillAppear:(BOOL)animated;

/**
 * Sent to the controller before the keyboard slides out.
 */
- (void)keyboardWillDisappear:(BOOL)animated;

/**
 *
 */
- (NSString*)titleForActivity;

/**
 *
 */
- (UIImage*)imageForNoData;

/**
 *
 */
- (NSString*)titleForNoData;

/**
 *
 */
- (NSString*)subtitleForNoData;

/**
 *
 */
- (UIImage*)imageForError:(NSError*)error;

/**
 *
 */
- (NSString*)titleForError:(NSError*)error;

/**
 *
 */
- (NSString*)subtitleForError:(NSError*)error;

/**
 *
 */
- (void)changeNavigationBarStyle:(UIBarStyle)barStyle barColor:(UIColor*)barColor
  statusBarStyle:(UIStatusBarStyle)statusBarStyle;

/**
 *
 */
- (void)restoreNavigationBarStyle;

@end
