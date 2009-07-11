#import "Three20/TTActionSheetController.h"

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
  [super dealloc];
}

- (void)didMoveToSuperview {
  if (!self.superview) {
    [_popupViewController release];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActionSheetController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithTitle:(NSString*)title delegate:(id)delegate
      cancelButtonTitle:(NSString*)cancelButtonTitle
      destructiveButtonTitle:(NSString*)destructiveButtonTitle
      otherButtonTitles:(NSString*)otherButtonTitles, ... {
  if (self = [super init]) {
    TTActionSheet* actionSheet = [[[TTActionSheet alloc] initWithTitle:title delegate:delegate
                                                         cancelButtonTitle:cancelButtonTitle
                                                         destructiveButtonTitle:destructiveButtonTitle
                                                         otherButtonTitles:nil] autorelease];
    actionSheet.popupViewController = self;

    va_list ap;
    va_start(ap, otherButtonTitles);
    while (otherButtonTitles) {
      [actionSheet addButtonWithTitle:otherButtonTitles];
      otherButtonTitles = va_arg(ap, id);
    }
    va_end(ap);
    
    self.view = actionSheet;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    TTActionSheet* actionSheet = [[[TTActionSheet alloc] init] autorelease];
    actionSheet.popupViewController = self;
    self.view = actionSheet;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPopupViewController

- (void)showInViewController:(UIViewController*)parentViewController animated:(BOOL)animated {
  [self.actionSheet showInView:parentViewController.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (UIActionSheet*)actionSheet {
  return (UIActionSheet*)self.view;
}

@end
