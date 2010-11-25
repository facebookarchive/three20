
#import "ActivityTestController.h"
#import <Three20/Three20.h>
#import <Three20UI/UIViewAdditions.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ActivityTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Activity Labels";
  }
  return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)addActivityLabelWithStyle:(TTActivityLabelStyle)style progress:(BOOL)progress {
  TTActivityLabel* label = [[[TTActivityLabel alloc] initWithStyle:style] autorelease];
  UIView* lastView = [self.view.subviews lastObject];
  label.text = @"Loading...";
  if (progress) {
    label.progress = 0.3;
  }
  [label sizeToFit];
  label.frame = CGRectMake(0, lastView.bottom+10, self.view.width, label.height);
  [self.view addSubview:label];
}

-(void)showLabelsWithProgress:(BOOL)progress {
  UIScrollView* scrollView = (UIScrollView*)self.view;
  [scrollView removeAllSubviews];

  if (progress) {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"No Progress"
      style:UIBarButtonItemStyleBordered target:self action:@selector(hideProgress)] autorelease];
  } else {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Progress"
      style:UIBarButtonItemStyleBordered target:self action:@selector(showProgress)] autorelease];
  }

  TTSearchlightLabel* label = [[[TTSearchlightLabel alloc] init] autorelease];
  label.text = @"Searchlight Label";
  label.font = [UIFont systemFontOfSize:25];
  label.textAlignment = UITextAlignmentCenter;
  label.contentMode = UIViewContentModeCenter;
  label.backgroundColor = [UIColor blackColor];
  [label sizeToFit];
  label.frame = CGRectMake(0, 0, self.view.width, label.height + 40);
  [self.view addSubview:label];
  [label startAnimating];

  [self addActivityLabelWithStyle:TTActivityLabelStyleWhiteBox progress:progress];
  [self addActivityLabelWithStyle:TTActivityLabelStyleBlackBox progress:progress];
  [self addActivityLabelWithStyle:TTActivityLabelStyleWhiteBezel progress:progress];
  [self addActivityLabelWithStyle:TTActivityLabelStyleBlackBezel progress:progress];
  [self addActivityLabelWithStyle:TTActivityLabelStyleGray progress:progress];
  [self addActivityLabelWithStyle:TTActivityLabelStyleWhite progress:progress];
  [self addActivityLabelWithStyle:TTActivityLabelStyleBlackBanner progress:progress];

  UIView* lastView = [scrollView.subviews lastObject];
  scrollView.contentSize = CGSizeMake(scrollView.width, lastView.bottom);
}

- (void)showProgress {
  [self showLabelsWithProgress:YES];
}

- (void)hideProgress {
  [self showLabelsWithProgress:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)loadView {
  UIScrollView* scrollView = [[[UIScrollView alloc] initWithFrame:TTNavigationFrame()] autorelease];
  scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
  self.view = scrollView;

  [self showLabelsWithProgress:NO];
}

@end
