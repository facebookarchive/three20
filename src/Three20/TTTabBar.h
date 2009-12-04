/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Three20/TTView.h"
#import "Three20/TTButton.h"

@class TTTabItem, TTTab, TTImageView, TTLabel;

@protocol TTTabDelegate;

@interface TTTabBar : TTView {
  id<TTTabDelegate> _delegate;
  NSString* _tabStyle;
  NSInteger _selectedTabIndex;
  NSArray* _tabItems;
  NSMutableArray* _tabViews;
}

@property(nonatomic,assign) id<TTTabDelegate> delegate;
@property(nonatomic,retain) NSArray* tabItems;
@property(nonatomic,readonly) NSArray* tabViews;
@property(nonatomic,copy) NSString* tabStyle;
@property(nonatomic,assign) TTTabItem* selectedTabItem;
@property(nonatomic,assign) TTTab* selectedTabView;
@property(nonatomic) NSInteger selectedTabIndex;

- (id)initWithFrame:(CGRect)frame;

- (void)showTabAtIndex:(NSInteger)tabIndex;
- (void)hideTabAtIndex:(NSInteger)tabIndex;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTabStrip : TTTabBar {
  TTView* _overflowLeft;
  TTView* _overflowRight;
  UIScrollView* _scrollView;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTabGrid : TTTabBar {
  NSInteger _columnCount;
}

@property(nonatomic) NSInteger columnCount;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTab : TTButton {
  TTTabItem* _tabItem;
  TTLabel* _badge;
}

@property(nonatomic,retain) TTTabItem* tabItem;

- (id)initWithItem:(TTTabItem*)item tabBar:(TTTabBar*)tabBar;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTTabItem : NSObject {
  NSString* _title;
  NSString* _icon;
  id _object;
  int _badgeNumber;
  TTTabBar* _tabBar;
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* icon;
@property(nonatomic,retain) id object;
@property(nonatomic) int badgeNumber;

- (id)initWithTitle:(NSString*)title;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTTabDelegate <NSObject>

- (void)tabBar:(TTTabBar*)tabBar tabSelected:(NSInteger)selectedIndex;

@end
