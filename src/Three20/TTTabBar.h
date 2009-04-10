#import "Three20/TTStyledView.h"
#import "Three20/TTButton.h"

@class TTTabItem, TTTabView, TTImageView, TTStyledLabel;

@protocol TTTabBarDelegate;

@interface TTTabBar : TTStyledView {
  id<TTTabBarDelegate> _delegate;
  NSString* _tabStyle;
  NSInteger _selectedTabIndex;
  TTStyledView* _overflowLeft;
  TTStyledView* _overflowRight;
  UIScrollView* _scrollView;
  NSArray* _tabItems;
  NSMutableArray* _tabViews;
}

@property(nonatomic,assign) id<TTTabBarDelegate> delegate;
@property(nonatomic,retain) NSArray* tabItems;
@property(nonatomic,readonly) NSArray* tabViews;
@property(nonatomic,copy) NSString* tabStyle;
@property(nonatomic,assign) TTTabItem* selectedTabItem;
@property(nonatomic,assign) TTTabView* selectedTabView;
@property(nonatomic) NSInteger selectedTabIndex;

- (id)initWithFrame:(CGRect)frame;

- (void)showTabAtIndex:(NSInteger)tabIndex;
- (void)hideTabAtIndex:(NSInteger)tabIndex;

@end

@interface TTTabView : TTButton {
  TTTabItem* _tabItem;
  TTStyledLabel* _badge;
}

@property(nonatomic,retain) TTTabItem* tabItem;

- (id)initWithItem:(TTTabItem*)item tabBar:(TTTabBar*)tabBar;

@end

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

@protocol TTTabBarDelegate <NSObject>

- (void)tabBar:(TTTabBar*)tabBar tabSelected:(NSInteger)selectedIndex;

@end
