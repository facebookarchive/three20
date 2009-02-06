// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/T3Global.h"

@class T3TabItem, T3TabView, T3ImageView;

typedef enum {
  T3TabBarStyleDark,
  T3TabBarStyleLight,
  T3TabBarStyleButtons
} T3TabBarStyle;

@protocol T3TabBarDelegate;

@interface T3TabBar : UIView {
  id<T3TabBarDelegate> _delegate;
  T3TabBarStyle _style;
  NSInteger _selectedTabIndex;
  UIImageView* _overflowLeft;
  UIImageView* _overflowRight;
  UIScrollView* _scrollView;
  NSArray* _tabItems;
  NSMutableArray* _tabViews;
  T3TabView* _trackingTab;
  UIColor* _textColor;
}

@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) NSArray* tabItems;
@property(nonatomic,readonly) NSArray* tabViews;
@property(nonatomic,assign) T3TabItem* selectedTabItem;
@property(nonatomic,assign) T3TabView* selectedTabView;
@property(nonatomic) NSInteger selectedTabIndex;
@property(nonatomic) CGPoint contentOffset;
@property(nonatomic,retain) UIColor* textColor;

- (id)initWithFrame:(CGRect)frame style:(T3TabBarStyle)style;

- (void)showTabAtIndex:(NSInteger)tabIndex;
- (void)hideTabAtIndex:(NSInteger)tabIndex;

@end

@interface T3TabView : UIControl {
  T3TabBarStyle _style;
  T3TabItem* _tabItem;
  UIImageView* _tabImage;
  T3ImageView* _iconView;
  UILabel* _titleLabel;
  UIImageView* _badgeImage;
  UILabel* _badgeLabel;
}

@property(nonatomic,retain) T3TabItem* tabItem;

- (id)initWithItem:(T3TabItem*)item tabBar:(T3TabBar*)tabBar style:(T3TabBarStyle)style;

@end

@interface T3TabItem : NSObject {
  NSString* _title;
  NSString* _icon;
  id _object;
  int _badgeNumber;
  T3TabBar* _tabBar;
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* icon;
@property(nonatomic,retain) id object;
@property(nonatomic) int badgeNumber;

- (id)initWithTitle:(NSString*)title;

@end

@protocol T3TabBarDelegate <NSObject>
- (void)tabBar:(T3TabBar*)tabBar tabSelected:(NSInteger)selectedIndex;
@end
