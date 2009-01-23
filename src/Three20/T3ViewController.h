#import "Three20/T3Global.h"

typedef enum {
  // Nothing needs to be updated
  T3ViewValid = 0,
  // Content needs to be updated
  T3ViewInvalidContent = 1,
  // Views need to be updated with the latest content
  T3ViewInvalidView = 2
} T3ViewValidity;

typedef enum {
  T3ViewContentNone,
  T3ViewContentActivity,
  T3ViewContentReady,
  T3ViewContentEmpty,
  T3ViewContentError
} T3ViewContentState;

@protocol T3Object;

/**
 * XXXjoe Re-write this as a short description of the class.
 * Purposes:
 *
 * 1. Postpone updating views until absolutely necessary
 * 2. Maintain state but release memory in the face of low memory conditions
 * 3. Persist and restore when app is shut down and restarts
 * 4. Display errors and activity information for externally loaded content
 */
@interface T3ViewController : UIViewController {
  NSDictionary* viewState;

  UIView* statusView;
  UIView* statusOverView;

  T3ViewValidity validity;
  T3ViewContentState contentState;
  NSString* contentActivityText;
  NSError* contentError;

  BOOL disabled;
  BOOL appearing;
  BOOL appeared;
  BOOL unloaded;
}

/**
 * The primary object behind the view.
 */
@property(nonatomic, readonly) id<T3Object> viewObject;

/**
 * A description of the kind of view to be presented for viewObject when the view is populated.
 */
@property(nonatomic, readonly) NSString* viewName;

/**
 * A temporary holding place for persisted view state waiting to be restored.
 */
@property(nonatomic, retain) NSDictionary* viewState;

/**
 * Indicates if content is ready, actively loading, empty, or has an error.
 */ 
@property(nonatomic) T3ViewContentState contentState;

/**
 * User interaction has been disabled;
 */
@property(nonatomic, readonly) BOOL disabled;

/**
 * The view has appeared at lease once.
 */
@property(nonatomic, readonly) BOOL appeared;

/**
 * The view is currently visible.
 */
@property(nonatomic, readonly) BOOL appearing;

/**
 * The view which displays activity, emptiness, or an error.
 *
 * This value is only non-nil when there is a status to be displayed.  By default, assigning
 * a view to this property will cause it to be displayed on top of all other views.
 */
@property(nonatomic, retain) UIView* statusView;

/**
 * Update the view with a new primary object.
 *
 * @param object The primary object to display.
 * @param name A description that hints at how to display the object.
 * @param state A dictionary of attributes persisted in a previous life.
 */
- (void)showObject:(id<T3Object>)object inView:(NSString*)name withState:(NSDictionary*)state;

/**
 * Persist attributes of the view to a dictionary that can be restored later.
 */
- (void)persistView:(NSMutableDictionary*)state;

/**
 * Restore attributes of the view from an earlier call to persistView.
 */
- (void)restoreView:(NSDictionary*)state;

/**
 * Invalidates the state of the view and schedules it to be updated as soon as possible.
 *
 * Invalidation functions allow you to change the state of the view without actually changing
 * the view.  This is necessary because low memory conditions can cause views to be destroyed
 * and re-created behind your back, so you need to maintain important state without them.
 */
- (void)invalidate:(T3ViewValidity)state;

/**
 * Changes the content state and invalidates the view so that it displays activity.
 */
- (void)setContentStateActivity:(NSString*)activityText;

/**
 * Changes the content state and invalidates the view so that it displays an error.
 */
- (void)setContentStateError:(NSError*)error;

/**
 * Reloads content from external source and invalidates the view.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)reloadContent;

/**
 * Called to update content after it has been invalidated.
 *
 * This is meant to be implemented by subclasses - the default merely invalidates the view.
 * 
 * This function is necessary because low memory conditions can cause views to be destroyed
 * and re-created behind your back, so you need to maintain content without them.  You should
 * not do anything here that relies on the existence of views, nor should you create views here.
 */
- (void)updateContent;

/**
 * Called when the view needs to be updated as a result of having been initialized or invalidated.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)updateView;
- (void)updateViewWithEmptiness;
- (void)updateViewWithActivity:(NSString*)activityText;
- (void)updateViewWithError:(NSError*)error;

/**
 * Restores a view to the state it was in after calling loadView but before calling updateView.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)resetView;

/**
 * Destroys all views prior to the controller itself being destroyed or going into hibernation
 * (due to a low memory warning).
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)unloadView;

/**
 * Displays a view that represents activity, an error, or emptiness.
 *
 * By default, this will show the view above all other views, covering the full bounds of
 * the controller's root view.  You may override this method to display the status view 
 * differently.
 */
- (void)showStatusView:(UIView*)view;

/**
 * Called after the view has been enabled.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)viewDidEnable;

/**
 * Called after the view has been disabled.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)viewDidDisable;

@end
