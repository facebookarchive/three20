#import "Three20/TTThumbView.h"
#import "Three20/TTImageView.h"
#import "Three20/TTStyledView.h"

@implementation TTThumbView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.opaque = YES;
    self.clipsToBounds = YES;
    
    [self setStylesWithClassName:@"thumbView:"];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)thumbURL {
  return [self imageForState:UIControlStateNormal];
}

- (void)setThumbURL:(NSString*)url {
  [self setImage:url forState:UIControlStateNormal];
}

@end
