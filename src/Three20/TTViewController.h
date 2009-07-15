#import "Three20/TTGlobal.h"

/** 
 * A view controller with some useful additions.
 */
@interface TTViewController : UIViewController {
  NSDictionary* _frozenState;
  UIBarStyle _navigationBarStyle;
  UIColor* _navigationBarTintColor;
  UIStatusBarStyle _statusBarStyle;
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
 * Sent to the controller before the keyboard slides in.
 */
- (void)keyboardWillAppear:(BOOL)animated;

/**
 * Sent to the controller before the keyboard slides out.
 */
- (void)keyboardWillDisappear:(BOOL)animated;

@end
