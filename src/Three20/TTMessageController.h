#import "Three20/TTModelViewController.h"
#import "Three20/TTTextEditor.h"

@protocol TTTableViewDataSource, TTMessageControllerDelegate;
@class TTPickerTextField, TTActivityLabel;

@interface TTMessageController : TTModelViewController <UITextFieldDelegate, TTTextEditorDelegate> {
  id<TTMessageControllerDelegate> _delegate;
  id<TTTableViewDataSource> _dataSource;
  NSArray* _fields;
  NSMutableArray* _fieldViews;
  UIScrollView* _scrollView;
  TTTextEditor* _textEditor;
  TTActivityLabel* _statusView;
  NSArray* _initialRecipients;
  BOOL _showsRecipientPicker;
  BOOL _isModified;
}

@property(nonatomic,assign) id<TTMessageControllerDelegate> delegate;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic,retain) NSArray* fields;
@property(nonatomic,retain) NSString* subject;
@property(nonatomic,retain) NSString* body;
@property(nonatomic) BOOL showsRecipientPicker;
@property(nonatomic,readonly) BOOL isModified;

- (id)initWithRecipients:(NSArray*)recipients;

- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex;

- (NSString*)textForFieldAtIndex:(NSUInteger)fieldIndex;
- (void)setText:(NSString*)text forFieldAtIndex:(NSUInteger)fieldIndex;

- (NSString*)titleForSending;

/**
 * Tells the delegate to send the message.
 */
- (void)send;

/**
 * Cancel the message, but confirm first with the user if necessary.
 */
- (void)cancel:(BOOL)confirmIfNecessary;

/**
 * Confirms with the user that it is ok to cancel.
 */
- (void)confirmCancellation;

/**
 *
 */
- (void)messageWillSend:(NSArray*)fields;

/**
 * The user touched the recipient picker button.
 */
- (void)messageWillShowRecipientPicker;

/**
 *
 */
- (void)messageDidSend;

/**
 * Determines if the message should cancel without confirming with the user.
 */
- (BOOL)messageShouldCancel;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTMessageControllerDelegate <NSObject>

@optional

- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields;

- (void)composeControllerWillCancel:(TTMessageController*)controller;

- (void)composeControllerShowRecipientPicker:(TTMessageController*)controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTMessageField : NSObject {
  NSString* _title;
  BOOL _required;
} 

@property(nonatomic,copy) NSString* title;
@property(nonatomic) BOOL required;

- (id)initWithTitle:(NSString*)title required:(BOOL)required;

@end

@interface TTMessageRecipientField : TTMessageField {
  NSArray* _recipients;
} 

@property(nonatomic,retain) NSArray* recipients;

@end

@interface TTMessageTextField : TTMessageField {
  NSString* _text;
} 

@property(nonatomic,copy) NSString* text;

@end

@interface TTMessageSubjectField : TTMessageTextField

@end
