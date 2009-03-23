#import "Three20/TTViewController.h"
#import "Three20/TTTextEditor.h"

@protocol TTTableViewDataSource, TTMessageControllerDelegate;
@class TTPickerTextField, TTActivityLabel;

@interface TTMessageController : TTViewController <UITextFieldDelegate, TTTextEditorDelegate> {
  id<TTMessageControllerDelegate> _delegate;
  id<TTTableViewDataSource> _dataSource;
  NSArray* _fields;
  NSMutableArray* _fieldViews;
  UINavigationBar* _navigationBar;
  UIScrollView* _scrollView;
  TTTextEditor* _textEditor;
  TTActivityLabel* _statusView;
  NSArray* _initialRecipients;
}

@property(nonatomic,assign) id<TTMessageControllerDelegate> delegate;
@property(nonatomic,retain) id<TTTableViewDataSource> dataSource;
@property(nonatomic,retain) NSArray* fields;

- (id)initWithRecipients:(NSArray*)recipients;

- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTMessageControllerDelegate <NSObject>

@optional

- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields;

- (void)composeControllerDidCancel:(TTMessageController*)controller;

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
