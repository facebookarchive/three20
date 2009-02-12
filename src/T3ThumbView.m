#import "Three20/T3ThumbView.h"
#import "Three20/T3ImageView.h"
#import "Three20/T3BackgroundView.h"

@implementation T3ThumbView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
    imageView = [[T3ImageView alloc] initWithFrame:CGRectZero];
    imageView.opaque = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    [self addSubview:imageView];

    borderView = [[T3BackgroundView alloc] initWithFrame:CGRectZero];
    borderView.opaque = NO;
    borderView.background = T3BackgroundRoundedRect;
    borderView.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    borderView.contentMode = UIViewContentModeRedraw;
    borderView.userInteractionEnabled = NO;
    [self addSubview:borderView];

    self.opaque = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.clipsToBounds = YES;
	}
	return self;
}

- (void)dealloc {
  [imageView release];
  [borderView release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  imageView.frame = self.bounds;
  borderView.frame = self.bounds;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if ([self pointInside:[touch locationInView:self] withEvent:event]) {
    return YES;
  } else {
    self.highlighted = NO;
    return NO;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  
  if (highlighted) {
    borderView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
  } else {
    borderView.fillColor = nil;
  }
  [borderView setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)url {
  return imageView.url;
}

- (void)setUrl:(NSString*)url {
  imageView.image = nil;
  imageView.url = url;
}

- (void)suspendLoading:(BOOL)suspended {
  if (suspended) {
    [imageView stopLoading];
  } else if (!imageView.image) {
    [imageView reload];
  }
}

@end
