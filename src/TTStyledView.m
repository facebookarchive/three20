#import "Three20/TTStyledView.h"
#import "Three20/TTStyle.h"
#import "Three20/TTShape.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledView

@synthesize style = _style, backgroundInset = _backgroundInset;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGRect)backgroundBounds {
  CGRect frame = self.frame;
  return CGRectMake(_backgroundInset.left, _backgroundInset.top,
    frame.size.width - (_backgroundInset.left + _backgroundInset.right),
    frame.size.height - (_backgroundInset.top + _backgroundInset.bottom));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _style = nil;
    _backgroundInset = UIEdgeInsetsZero;

    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  [_style release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  CGRect bounds = self.backgroundBounds;
  TTRectangleShape* shape = [TTRectangleShape shape];
  if (![self.style drawRect:bounds shape:shape delegate:self]) {
    [self drawContent:rect];
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize styleSize = [_style addToSize:CGSizeZero delegate:self];
  UIEdgeInsets insets = [_style addToInsets:UIEdgeInsetsZero forSize:styleSize];
  return CGSizeMake(styleSize.width + insets.left + insets.right,
                    styleSize.height + insets.top + insets.bottom);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyleDelegate

- (void)drawLayer:(CGRect)rect withStyle:(TTStyle*)style shape:(TTShape*)shape {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)drawContent:(CGRect)rect {
}

@end
