#import "Three20/TTViewController.h"
#import "Three20/TTTextEditor.h"

@protocol TTSearchSource, TTComposeControllerDelegate;
@class TTMenuTextField;

@interface TTComposeController : TTViewController <UITextFieldDelegate, TTTextEditorDelegate> {
  id<TTComposeControllerDelegate> _delegate;
  id<TTSearchSource> _searchSource;
  NSArray* _fields;
  NSMutableArray* _fieldViews;
  UINavigationBar* _navigationBar;
  UIScrollView* _scrollView;
  TTTextEditor* _textEditor;
  NSArray* _initialRecipients;
}

@property(nonatomic,assign) id<TTComposeControllerDelegate> delegate;
@property(nonatomic,retain) id<TTSearchSource> searchSource;
@property(nonatomic,retain) NSArray* fields;

- (id)initWithRecipients:(NSArray*)recipients;

- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTComposeControllerDelegate <NSObject>

@optional

- (void)composeController:(TTComposeController*)controller didSendFields:(NSArray*)fields;

- (void)composeControllerDidCancel:(TTComposeController*)controller;

- (void)composeControllerShowRecipientPicker:(TTComposeController*)controller;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTComposerField : NSObject {
  NSString* _title;
  BOOL _required;
} 

@property(nonatomic,copy) NSString* title;
@property(nonatomic) BOOL required;

- (id)initWithTitle:(NSString*)title required:(BOOL)required;

@end

@interface TTComposerRecipientField : TTComposerField {
  NSArray* _recipients;
} 

@property(nonatomic,retain) NSArray* recipients;

@end

@interface TTComposerTextField : TTComposerField {
  NSString* _text;
} 

@property(nonatomic,copy) NSString* text;

@end

@interface TTComposerSubjectField : TTComposerTextField

@end
