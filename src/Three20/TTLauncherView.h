//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TTLauncherViewDelegate;
@class TTPageControl, TTLauncherButton, TTLauncherItem;

@interface TTLauncherView : UIView <UIScrollViewDelegate> {
  id<TTLauncherViewDelegate> _delegate;
  NSMutableArray* _pages;
  NSInteger _columnCount;
  NSInteger _rowCount;
  NSString* _prompt;
  NSMutableArray* _buttons;
  UIScrollView* _scrollView;
  TTPageControl* _pager;
  NSTimer* _editHoldTimer;
  NSTimer* _springLoadTimer;
  TTLauncherButton* _dragButton;
  UITouch* _dragTouch;
  NSInteger _positionOrigin;
  CGPoint _dragOrigin;
  CGPoint _touchOrigin;
  BOOL _editing;
  BOOL _springing;
}

/**
 *
 */
@property(nonatomic,assign) id<TTLauncherViewDelegate> delegate;

/**
 *
 */
@property(nonatomic,copy) NSArray* pages;

/**
 *
 */
@property(nonatomic) NSInteger columnCount;

/**
 *
 */
@property(nonatomic,readonly) NSInteger rowCount;

/**
 *
 */
@property(nonatomic) NSInteger currentPageIndex;

/**
 *
 */
@property(nonatomic,copy) NSString* prompt;

/**
 *
 */
@property(nonatomic,readonly) BOOL editing;

/**
 *
 */
- (void)addItem:(TTLauncherItem*)item animated:(BOOL)animated;

/**
 *
 */
- (void)removeItem:(TTLauncherItem*)item animated:(BOOL)animated;

/**
 *
 */
- (TTLauncherItem*)itemWithURL:(NSString*)URL;

/**
 *
 */
- (NSIndexPath*)indexPathOfItem:(TTLauncherItem*)item;

/**
 *
 */
- (void)scrollToItem:(TTLauncherItem*)item animated:(BOOL)animated;

/**
 *
 */
- (void)beginEditing;

/**
 *
 */
- (void)endEditing;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTLauncherViewDelegate <NSObject>

@optional

- (void)launcherView:(TTLauncherView*)launcher didAddItem:(TTLauncherItem*)item;

- (void)launcherView:(TTLauncherView*)launcher didRemoveItem:(TTLauncherItem*)item;

- (void)launcherView:(TTLauncherView*)launcher didMoveItem:(TTLauncherItem*)item;

- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item;

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher;

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher;

@end
