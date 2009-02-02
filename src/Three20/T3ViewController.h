#import "Three20/T3Global.h"

typedef enum {
  T3ViewValid = 0,            // Nothing needs to be updated
  T3ViewInvalidContent = 1,   // Content needs to be updated
  T3ViewInvalidView = 2       // Views need to be updated with the latest content
} T3ViewControllerState;

typedef enum {
  T3ContentUnknown = 0,
  T3ContentNone = 1,
  T3ContentReady = 2,
  T3ContentActivity = 4,
  T3ContentError = 8
} T3ContentState;

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
  UIView* _statusView;
  NSDictionary* _viewState;
  T3ViewControllerState _validity;
  T3ContentState _contentState;
  NSError* _contentError;

  BOOL _appearing;
  BOOL _appeared;
  BOOL _unloaded;
}

/**
 * The primary object behind the view.
 */
@property(nonatomic,readonly) id<T3Object> viewObject;

/**
 * A description of the kind of view to be presented for viewObject when the view is populated.
 */
@property(nonatomic,readonly) NSString* viewType;

/**
 * A temporary holding place for persisted view state waiting to be restored.
 */
@property(nonatomic,retain) NSDictionary* viewState;

/**
 * Indicates if content is ready, actively loading, empty, or has an error.
 */ 
@property(nonatomic) T3ContentState contentState;

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
 * Update the view with a new primary object.
 *
 * @param object The primary object to display.
 * @param name A description that hints at how to display the object.
 * @param state A dictionary of attributes persisted in a previous life.
 */
- (void)showObject:(id<T3Object>)object inView:(NSString*)viewType withState:(NSDictionary*)state;

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
- (void)invalidate:(T3ViewControllerState)state;

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
 * Called to update the view after it has been invalidated.
 *
 * Override this function and check contentState to decide how to update the view.  The default
 * implementation will update the view to indicate activity, errors, and lack of content.
 */
- (void)updateView;

/**
 * Reloads content from external source and invalidates the view.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)reloadContent;

/**
 * Restores a view to the state it was in after calling loadView but before calling updateView;
 * in other words, the views have no content in them yet.
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
 *
 */
- (NSString*)titleForActivity;

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
- (NSString*)descriptionForError:(NSError*)error;

/**
 *
 */
- (UIImage*)imageForNoContent;

/**
 *
 */
- (NSString*)titleForNoContent;

/**
 *
 */
- (NSString*)descriptionForNoContent;

@end
