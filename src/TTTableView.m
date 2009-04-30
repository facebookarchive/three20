#import "Three20/TTTableView.h"
#import "Three20/TTStyledNode.h"
#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTNavigationCenter.h"
#import "Three20/TTTableViewDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const CGFloat kCancelHighlightThreshold = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTTableView

@synthesize highlightedLabel = _highlightedLabel;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)hideMenuAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished
        context:(void*)context {
  UIView* menuView = (UIView*)context;
  [menuView removeFromSuperview];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
  if (self = [super initWithFrame:frame style:style]) {
    _highlightedLabel = nil;
    _highlightStartPoint = CGPointZero;
    _menuView = nil;
    _menuCell = nil;
    
    self.delaysContentTouches = NO;
  }
  return self;
}

- (void)dealloc {
  [_highlightedLabel release];
  [_menuView release];
  [_menuCell release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesBegan:touches withEvent:event];

  if (_highlightedLabel) {
    UITouch* touch = [touches anyObject];
    _highlightStartPoint = [touch locationInView:self];
  }
  
  if ([self.delegate isKindOfClass:[TTTableViewDelegate class]]) {
    TTTableViewDelegate* delegate = (TTTableViewDelegate*)self.delegate;
    [delegate.controller touchesBegan:touches withEvent:event];
  }
  
  if (_menuView) {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_menuView];
    if (point.y < 0 || point.y > _menuView.height) {
      [self hideMenu:YES];
    } else {
      UIView* hit = [_menuView hitTest:point withEvent:event];
      if (![hit isKindOfClass:[UIControl class]]) {
        [self hideMenu:YES];
      }
    }
  }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesMoved:touches withEvent:event];

  if (_highlightedLabel) {
    UITouch* touch = [touches anyObject];
    CGPoint newPoint = [touch locationInView:self];
    CGFloat dx = newPoint.x - _highlightStartPoint.x;
    CGFloat dy = newPoint.y - _highlightStartPoint.y;
    CGFloat d = sqrt((dx*dx) + (dy+dy));
    if (d > kCancelHighlightThreshold) {
      _highlightedLabel.highlightedNode = nil;
      self.highlightedLabel = nil;
    }
  }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesEnded:touches withEvent:event];

  if (_highlightedLabel) {
    TTStyledElement* element = _highlightedLabel.highlightedNode;
    [element performDefaultAction];
  } else {
    if ([self.delegate isKindOfClass:[TTTableViewDelegate class]]) {
      TTTableViewDelegate* delegate = (TTTableViewDelegate*)self.delegate;
      [delegate.controller touchesEnded:touches withEvent:event];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableView

- (void)reloadData {
  if (_menuView) {
    [self hideMenu:NO];
  }
  [super reloadData];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
        scrollPosition:(UITableViewScrollPosition)scrollPosition {
  if (!_highlightedLabel) {
    [super selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setHighlightedLabel:(TTStyledTextLabel*)label {
  if (label != _highlightedLabel) {
    _highlightedLabel.highlightedNode = nil;
    [_highlightedLabel release];
    _highlightedLabel = [label retain];
  }
}

- (void)showMenu:(UIView*)view forCell:(UITableViewCell*)cell animated:(BOOL)animated {
  [self hideMenu:YES];

  _menuView = [view retain];
  _menuCell = [cell retain];
  
  // Insert the cell below all content subviews
  [_menuCell.contentView insertSubview:_menuView atIndex:0];

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
  }

  // Move each content subview down, revealing the menu
  for (UIView* view in _menuCell.contentView.subviews) {
    if (view != _menuView) {
      view.top += _menuCell.contentView.height;
    }
  }
  
  if (animated) {
    [UIView commitAnimations];
  }
}

- (void)hideMenu:(BOOL)animated {
  if (_menuView) {
    if (animated) {
      [UIView beginAnimations:nil context:_menuView];
      [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(hideMenuAnimationDidStop:finished:context:)];
    }

    for (UIView* view in _menuCell.contentView.subviews) {
      if (view != _menuView) {
        view.top -= _menuCell.contentView.height;
      }
    }

    if (animated) {
      [UIView commitAnimations];
    } else {
      [_menuView removeFromSuperview];
    }

    [_menuView release];
    _menuView = nil;
    [_menuCell release];
    _menuCell = nil;
  }
}

@end
