#import "Three20/TTGlobal.h"

/**
 * A protocol that allows a view controller to play nice with TTNavigationCenter.
 */
@protocol TTNavigableViewController

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
- (void)showObject:(id)object inView:(NSString*)viewType withState:(NSDictionary*)state;

/**
 * Persist attributes of the view to a dictionary that can be restored later.
 */
- (void)persistView:(NSMutableDictionary*)state;

/**
 * Restore attributes of the view from an earlier call to persistView.
 */
- (void)restoreView:(NSDictionary*)state;

@end
