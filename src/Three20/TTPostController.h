// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTPopupViewController.h"
#import "Three20/TTTextEditor.h"

@protocol TTPostControllerDelegate;
@class TTActivityLabel;

@interface TTPostController : TTPopupViewController <TTTextEditorDelegate> {
  id<TTPostControllerDelegate> _delegate;
  id _result;
  NSString* _defaultText;
  CGRect _originRect;
  UIView* _originView;
  TTTextEditor* _textEditor;
  UINavigationBar* _navigationBar;
  UIView* _screenView;
  TTActivityLabel* _activityView;
  BOOL _originalStatusBarHidden;
  UIStatusBarStyle _originalStatusBarStyle;
}

@property(nonatomic,assign) id<TTPostControllerDelegate> delegate;
@property(nonatomic,retain) id result;
@property(nonatomic,readonly) TTTextEditor* textEditor;
@property(nonatomic,readonly) UINavigationBar* navigatorBar;
@property(nonatomic,retain) UIView* originView;

/**
 * Posts the text to delegates, who have to actually do something with it.
 */
- (void)post;

/**
 * Cancels the controller, but confirms with the user if they have entered text.
 */
- (void)cancel;

/**
 * Dismisses the controller with a resulting that is sent to the delegate.
 */
- (void)dismissWithResult:(id)result animated:(BOOL)animated;

/**
 * Notifies the user of an error and resets the editor to normal.
 */
- (void)failWithError:(NSError*)error;

/**
 * The users has entered text and posted it.
 *
 * Subclasses can implement this to handle the text before it is sent to the delegate. The
 * default returns NO.
 *
 * @return YES if the controller should be dismissed immediately.
 */
- (BOOL)willPostText:(NSString*)text;

/**
 *
 */
- (NSString*)titleForActivity;

/**
 *
 */
- (NSString*)titleForError:(NSError*)error;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTPostControllerDelegate <NSObject>

@optional

/**
 * The user has posted text and an animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text;


/**
 * The text will animate towards a rectangle.
 *
 * @return the rect in screen coordinates where the text should animate towards.
 */
- (CGRect)postController:(TTPostController*)postController willAnimateTowards:(CGRect)rect;

/**
 * The text has been posted.
 */
- (void)postController:(TTPostController*)postController didPostText:(NSString*)text
        withResult:(id)result;

/**
 * The controller was cancelled before posting.
 */
- (void)postControllerDidCancel:(TTPostController*)postController;

@end
