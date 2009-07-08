#import "ContentController.h"

@implementation ContentController

@synthesize content = _content;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithWaitress:(NSString*)waitress params:(NSDictionary*)params {
  if (self = [super init]) {
    NSString* ref = [params objectForKey:@"ref"];
    TTLOG(@"ORDER REFERRED FROM %@", ref);
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
        target:self action:@selector(dismiss)] autorelease];

    self.title = @"Place Your Order";
    self.content = [NSString stringWithFormat:@"%@ will take your order now.", waitress];
  }
  return self;
}

- (id)initWithFood:(NSString*)food {
  if (self = [super init]) {
    self.title = food;
    self.content = [NSString stringWithFormat:@"<b>%@</b> is just food, ya know?", food];
  }
  return self;
}

- (id)initWithAbout:(NSString*)about {
  if (self = [super init]) {
    if ([about isEqualToString:@"story"]) {
      self.title = @"Our Story";
    } else if ([about isEqualToString:@"complaints"]) {
      self.title = @"Complaints Dept.";
    }

    self.content = [NSString stringWithFormat:@"<b>%@</b> is the name of this page.  Exciting.", about];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _content = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_MEMBER(_content);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];
  
  CGRect frame = CGRectInset(self.view.bounds, 20, 20);
  TTStyledTextLabel* label = [[[TTStyledTextLabel alloc] initWithFrame:frame] autorelease];
  label.tag = 42;
  label.font = [UIFont systemFontOfSize:22];
  [self.view addSubview:label];
}

- (void)updateView {
  TTStyledTextLabel* label = (TTStyledTextLabel*)[self.view viewWithTag:42];
  label.html = _content;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setContent:(NSString*)content {
  if (content != _content) {
    [_content release];
    _content = [content copy];
  }
}

@end
 