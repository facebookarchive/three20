// Copyright 2004-2009 Facebook. All Rights Reserved.

#import "Three20/T3Global.h"

@class T3TabItem, T3TabView, T3ImageView;

typedef enum {
  T3TabBarStyleDark,
  T3TabBarStyleLight,
  T3TabBarStyleButtons
} T3TabBarStyle;

@interface T3TabBar : UIView {
  id delegate;
  T3TabBarStyle style;
  NSInteger selectedTabIndex;
  UIImageView* overflowLeft;
  UIImageView* overflowRight;
  UIScrollView* scrollView;
  NSArray* tabItems;
  NSMutableArray* tabViews;
  T3TabView* trackingTab;
  UIColor* textColor;
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
  T3TabBarStyle style;
  T3TabItem* tabItem;
  UIImageView* tabImage;
  T3ImageView* iconView;
  UILabel* titleLabel;
  UIImageView* badgeImage;
  UILabel* badgeLabel;
}

@property(nonatomic,retain) T3TabItem* tabItem;

- (id)initWithItem:(T3TabItem*)item tabBar:(T3TabBar*)tabBar style:(T3TabBarStyle)style;

@end

@interface T3TabItem : NSObject {
  id delegate;
  NSString* title;
  NSString* icon;
  id object;
  int badgeNumber;
}

@property(nonatomic,assign) id delegate;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* icon;
@property(nonatomic,retain) id object;
@property(nonatomic) int badgeNumber;

- (id)initWithTitle:(NSString*)title;

@end
