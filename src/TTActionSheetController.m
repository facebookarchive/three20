#import "Three20/TTActionSheetController.h"
#import "Three20/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTActionSheet : UIActionSheet {
  UIViewController* _popupViewController;
}

@property(nonatomic,retain) UIViewController* popupViewController;

@end

@implementation TTActionSheet

@synthesize popupViewController = _popupViewController;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _popupViewController = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_popupViewController);
  [super dealloc];
}

- (void)didMoveToSuperview {
  if (!self.superview) {
    [_popupViewController autorelease];
    _popupViewController = nil;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActionSheetController

@synthesize delegate = _delegate, userInfo = _userInfo;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title delegate:(id)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _userInfo = nil;
    _URLs = [[NSMutableArray alloc] init];
    
    if (title) {
      self.actionSheet.title = title;
    }
  }
  return self;
}

- (id)initWithTitle:(NSString*)title {
  return [self initWithTitle:title delegate:nil];
}

- (id)init {
  return [self initWithTitle:nil delegate:nil];
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URLs);
  TT_RELEASE_SAFELY(_userInfo);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  TTActionSheet* actionSheet = [[[TTActionSheet alloc] initWithTitle:nil delegate:self
                                                       cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                       otherButtonTitles:nil] autorelease];
  actionSheet.popupViewController = self;
  self.view = actionSheet;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UTViewController (TTCategory)

- (BOOL)persistView:(NSMutableDictionary*)state {
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self viewWillAppear:animated];
  [self.actionSheet showInView:view];
  [self viewDidAppear:animated];
}

- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  [self viewWillDisappear:animated];
  [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex
                    animated:animated];
  [self viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
    [_delegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
  }
}

- (void)actionSheetCancel:(UIActionSheet*)actionSheet {
  if ([_delegate respondsToSelector:@selector(actionSheetCancel:)]) {
    [_delegate actionSheetCancel:actionSheet];
  }
}

- (void)willPresentActionSheet:(UIActionSheet*)actionSheet {
  if ([_delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
    [_delegate willPresentActionSheet:actionSheet];
  }
}

- (void)didPresentActionSheet:(UIActionSheet*)actionSheet {
  if ([_delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
    [_delegate didPresentActionSheet:actionSheet];
  }
}

- (void)actionSheet:(UIActionSheet*)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if ([_delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
    [_delegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
  }
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSString* URL = [self buttonURLAtIndex:buttonIndex];
  BOOL canOpenURL = YES;
  if ([_delegate respondsToSelector:@selector(actionSheetController:didDismissWithButtonIndex:URL:)]) {
    canOpenURL = [_delegate actionSheetController:self didDismissWithButtonIndex:buttonIndex URL:URL];
  }
  if (URL && canOpenURL) {
    TTOpenURL(URL);
  }

  if ([_delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
    [_delegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIActionSheet*)actionSheet {
  return (UIActionSheet*)self.view;
}

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  if (URL) {
    [_URLs addObject:URL];
  } else {
    [_URLs addObject:[NSNull null]];
  }
  return [self.actionSheet addButtonWithTitle:title];
}

- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.actionSheet.cancelButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.actionSheet.cancelButtonIndex;
}

- (NSInteger)addDestructiveButtonWithTitle:(NSString*)title URL:(NSString*)URL {
  self.actionSheet.destructiveButtonIndex = [self addButtonWithTitle:title URL:URL];
  return self.actionSheet.destructiveButtonIndex;
}

- (NSString*)buttonURLAtIndex:(NSInteger)index {
  if (index < _URLs.count) {
    id URL = [_URLs objectAtIndex:index];
    return URL != [NSNull null] ? URL : nil;
  } else {
    return nil;
  }
}

@end
