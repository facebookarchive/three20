#import "Three20/TTGlobal.h"

typedef enum {
  TTContentUnknown = 0,
  TTContentNone = 1,
  TTContentReady = 2,
  TTContentActivity = 4,
  TTContentError = 8
} TTContentState;

@protocol TTObject;

/**
 * XXXjoe Re-write this as a short description of the class.
 * Purposes:
 *
 * 1. Postpone updating views until absolutely necessary
 * 2. Maintain state but release memory in the face of low memory conditions
 * 3. Persist and restore when app is shut down and restarts
 * 4. Display errors and activity information for externally loaded content
 */
@interface TTViewController : UIViewController {
  UIView* _statusView;
  NSDictionary* _viewState;
  TTContentState _contentState;
  NSError* _contentError;
  
  UINavigationBar* _previousBar;
  UIBarStyle _previousBarStyle;
  UIColor* _previousBarTintColor;
  UIStatusBarStyle _previousStatusBarStyle;

  BOOL _invalid;
  BOOL _appearing;
  BOOL _appeared;
  BOOL _unloaded;
  BOOL _autoresizesForKeyboard;
}

/**
 * The primary object behind the view.
 */
@property(nonatomic,readonly) id<TTObject> viewObject;

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
@property(nonatomic) TTContentState contentState;

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
- (void)showObject:(id<TTObject>)object inView:(NSString*)viewType withState:(NSDictionary*)state;

/**
 * Persist attributes of the view to a dictionary that can be restored later.
 */
- (void)persistView:(NSMutableDictionary*)state;

/**
 * Restore attributes of the view from an earlier call to persistView.
 */
- (void)restoreView:(NSDictionary*)state;

/**
 * Invalidates the state of the content and view and schedules it to be updated as soon as possible.
 *
 * Invalidation functions allow you to change the state of the view without actually changing
 * the view.  This is necessary because low memory conditions can cause views to be destroyed
 * and re-created behind your back, so you need to maintain important state without them.
 */
- (void)invalidate;

/**
 * Updates the content and view if they are invalid.
 */
- (void)validate;

/**
 * Called to update the content state after the primary view object has changed.
 *
 * You should not call this directly.  Subclasses should implement this method and set
 * contentState to reflect the state of the primary view object. You should not do anything
 * here that relies on the existence of views, nor should you create views here.
 *
 * This is meant to be implemented by subclasses - the default sets contentState to ready.  
 */
- (void)updateContent;

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
 * Reloads content from external sources.
 *
 * This is meant to be implemented by subclasses - the default does nothing.
 */
- (void)reloadContent;

/**
 * Called to update the view after it has been invalidated.
 *
 * Override this function and check contentState to decide how to update the view.  Do not call
 * super unless you want it to display activity, error, and no content states.
 *
 * This is meant to be implemented by subclasses - the default will update the view to indicate
 * activity, errors, and lack of content.
 */
- (void)updateView;

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
- (UIImage*)imageForNoContent;

/**
 *
 */
- (NSString*)titleForNoContent;

/**
 *
 */
- (NSString*)subtitleForNoContent;

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
