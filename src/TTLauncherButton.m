// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTLauncherButton.h"
#import "Three20/TTLauncherItem.h"
#import "Three20/TTLauncherView.h"
#import "Three20/TTURLCache.h"
#import "Three20/TTURLResponse.h"
#import "Three20/TTLabel.h"
#import "Three20/TTDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kPadding = 4;
static const CGFloat kShadowSize = 2;
static const CGFloat kImageSize = 50;
static const CGFloat kBadgeMarginX = 11;
static const CGFloat kBadgeMarginY = 7;
static const NSInteger kMaxBadgeNumber = 99;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTLauncherButton

@synthesize item = _item, closeButton = _closeButton, editing = _editing, dragging = _dragging;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)isAppButton {
  return [_item.image hasPrefix:@"bundle://"];
}

- (void)updateBadge {
  if (!_badge && _item.badgeNumber) {
    _badge = [[TTLabel alloc] initWithFrame:CGRectMake(kBadgeMarginX,kBadgeMarginY,0,0)];
    _badge.style = TTSTYLE(largeBadge);
    _badge.backgroundColor = [UIColor clearColor];
    _badge.userInteractionEnabled = NO;
    [self addSubview:_badge];
  }

  if (_item.badgeNumber <= kMaxBadgeNumber) {
    _badge.text = [NSString stringWithFormat:@"%d", _item.badgeNumber];
  } else {
    _badge.text = [NSString stringWithFormat:@"%d+", kMaxBadgeNumber];
  }
  _badge.hidden = !_item.badgeNumber;
  [_badge sizeToFit];
  _badge.left = self.width - (_badge.width + kBadgeMarginX);
}

- (void)updateLabel {
  _titleLabel.highlighted = (self.highlighted || self.selected) && !_dragging;
//  if (_titleLabel.highlighted && !_dragging) {
//    _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
//  } else {
//    _titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.7];
//  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithItem:(TTLauncherItem*)item {
  if (self = [self init]) {
    _item = [item retain];
    _titleLabel.text = [[NSBundle mainBundle] localizedStringForKey:item.title value:nil table:nil];
    [self updateBadge];
    if (item.image) {
      _image = [[[TTURLCache sharedCache] imageForURL:item.image] retain];
      if (!_image) {
        TTURLRequest* request = [TTURLRequest requestWithURL:item.image delegate:self];
        request.response = [[[TTURLImageResponse alloc] init] autorelease];
        [request send];
      }
    }
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _item = nil;
    _image = nil;
    _imageRequest = nil;
    _badge = nil;
    _closeButton = nil;
    _dragging = NO;
    _editing = NO;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _titleLabel.textColor = RGBCOLOR(50,50,50);
//    _titleLabel.highlightedTextColor = RGBCOLOR(255, 255, 255);
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.minimumFontSize = 11;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self addSubview:_titleLabel];
    
//    [self setStylesWithSelector:@"launcherButton:"];
    [self updateLabel];
  }
  return self;
}

- (void)dealloc {
  [_imageRequest cancel];
  TT_RELEASE_SAFELY(_item);
  TT_RELEASE_SAFELY(_titleLabel);
  TT_RELEASE_SAFELY(_badge);
  TT_RELEASE_SAFELY(_closeButton);
  TT_RELEASE_SAFELY(_image);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  [[self nextResponder] touchesMoved:touches withEvent:event];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControl

- (BOOL)isHighlighted {
  return !_dragging && [super isHighlighted];
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self updateLabel];
}

- (BOOL)isSelected {
  return !_dragging && [super isSelected];
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  [self updateLabel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  if (_image) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    if (self.highlighted || self.selected) {
      CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    }

    CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 2, RGBACOLOR(0,0,0,0.3).CGColor);
    CGContextBeginTransparencyLayer(ctx, nil);

    if ([self isAppButton]) {
      CGRect imageRect = CGRectMake(floor(rect.size.width/2 - _image.size.width/2) + 1,
                                    floor(rect.size.height/2 - _image.size.height/2) - 7,
                                    _image.size.width, _image.size.height);

      [_image drawInRect:imageRect];
    } else {
      CGRect roundRect = CGRectMake(floor(rect.size.width/2 - (kImageSize - kShadowSize)/2),
                                    floor(rect.size.height/2 - kImageSize/2) - 9,
                                    kImageSize, kImageSize);

      [_image drawInRect:roundRect radius:5 contentMode:UIViewContentModeScaleAspectFill];
    }

    CGContextEndTransparencyLayer(ctx);

    CGContextRestoreGState(ctx);
  }
}

- (void)layoutSubviews {
  [_titleLabel sizeToFit];
  CGFloat iconHeight = 50;
  CGFloat padding = floor((self.height - (iconHeight + _titleLabel.height))/4);
  CGFloat y = round(self.height/2 - (iconHeight + _titleLabel.height)/2) + iconHeight + padding;
  _titleLabel.frame = CGRectMake(kPadding, y,
                                 self.width - kPadding*2, _titleLabel.height);
  if (_badge) {
    _badge.origin = CGPointMake(self.width - (_badge.width + kBadgeMarginX), kBadgeMarginY);
  }
  
  if (_closeButton) {
    _closeButton.origin = CGPointMake(kBadgeMarginX, kBadgeMarginY);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
  _imageRequest = [request retain];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  _image = [response.image retain];
  [self setNeedsDisplay];
  
  TT_RELEASE_SAFELY(_imageRequest);
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_imageRequest);
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_imageRequest);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTButton*)closeButton {
  if (!_closeButton && ![self isAppButton]) {
    _closeButton = [[TTButton buttonWithStyle:@"launcherCloseButton:"] retain];
    [_closeButton setImage:@"bundle://Three20.bundle/images/closeButton.png"
                  forState:UIControlStateNormal];
    _closeButton.size = CGSizeMake(26,29);
  }
  return _closeButton;
}

- (void)setDragging:(BOOL)dragging {
  if (_dragging != dragging) {
    _dragging = dragging;

    if (dragging) {
      self.transform = CGAffineTransformMakeScale(1.4, 1.4);
      self.alpha = 0.7;
    } else {
      self.transform = CGAffineTransformIdentity;
      self.alpha = 1;
    }
    [self updateLabel];
  }
}

- (void)setEditing:(BOOL)editing {
  if (_editing != editing) {
    _editing = editing;

    if (editing) {
      [self addSubview:self.closeButton];
    } else {
      [_closeButton removeFromSuperview];
      TT_RELEASE_SAFELY(_closeButton);
    }
  }
}

@end
