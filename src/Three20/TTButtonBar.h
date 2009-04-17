// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/TTView.h"

/**
 * A box containing buttons with a consistent style.
 */
@interface TTButtonBar : TTView {
  NSMutableArray* _buttons;
  NSString* _buttonStyle;
}

@property(nonatomic, retain) NSArray* buttons;
@property(nonatomic,copy) NSString* buttonStyle;

- (void)addButton:(NSString*)title target:(id)target action:(SEL)selector;
- (void)removeButtons;

@end
