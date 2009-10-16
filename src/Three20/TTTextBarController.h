#import "Three20/TTPopupViewController.h"
#import "Three20/TTTextEditor.h"

@protocol TTTextBarDelegate;
@class TTButton;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTextBarController : TTPopupViewController <TTTextEditorDelegate> {
  id <TTTextBarDelegate> _delegate;
  id _result;
  NSString* _defaultText;
  TTView* _textBar;
  TTTextEditor* _textEditor;
  TTButton* _postButton;
  UIView* _footerBar;
  CGFloat _originTop;
  UIBarButtonItem* _previousRightBarButtonItem;
}

@property(nonatomic,assign) id <TTTextBarDelegate> delegate;
@property(nonatomic,readonly) TTTextEditor* textEditor;
@property(nonatomic,readonly) TTButton* postButton;
@property(nonatomic,retain) UIView* footerBar;

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

@protocol TTTextBarDelegate <NSObject>

@optional

/**
 *
 */
- (void)textBarDidBeginEditing:(TTTextBarController*)textBar;

/**
 *
 */
- (void)textBarDidEndEditing:(TTTextBarController*)textBar;

/**
 * The user has posted text and an animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)textBar:(TTTextBarController*)textBar willPostText:(NSString*)text;

/**
 * The text has been posted.
 */
- (void)textBar:(TTTextBarController*)textBar didPostText:(NSString*)text
        withResult:(id)result;

/**
 * The controller was cancelled before posting.
 */
- (void)textBarDidCancel:(TTTextBarController*)textBar;

@end
