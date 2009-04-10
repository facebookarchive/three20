#import "Three20/TTGlobal.h"

@class TTTabItem, TTTabView, TTImageView, TTBadgeView;

typedef enum {
  TTTabBarStyleDark,
  TTTabBarStyleLight,
  TTTabBarStyleButtons
} TTTabBarStyle;

@protocol TTTabBarDelegate;

@interface TTTabBar : UIView {
  id<TTTabBarDelegate> _delegate;
  TTTabBarStyle _style;
  NSInteger _selectedTabIndex;
  UIImageView* _overflowLeft;
  UIImageView* _overflowRight;
  UIScrollView* _scrollView;
  NSArray* _tabItems;
  NSMutableArray* _tabViews;
  UIColor* _textColor;
  UIColor* _tintColor;
  UIImage* _tabImage;
}

@property(nonatomic,assign) id delegate;
@property(nonatomic,retain) NSArray* tabItems;
@property(nonatomic,readonly) NSArray* tabViews;
@property(nonatomic,assign) TTTabItem* selectedTabItem;
@property(nonatomic,assign) TTTabView* selectedTabView;
@property(nonatomic) NSInteger selectedTabIndex;
@property(nonatomic) CGPoint contentOffset;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic,retain) UIImage* tabImage;

- (id)initWithFrame:(CGRect)frame style:(TTTabBarStyle)style;

- (void)showTabAtIndex:(NSInteger)tabIndex;
- (void)hideTabAtIndex:(NSInteger)tabIndex;

@end

@interface TTTabView : UIControl {
  TTTabBarStyle _style;
  TTTabItem* _tabItem;
  UIImageView* _tabImage;
  TTImageView* _iconView;
  UILabel* _titleLabel;
  TTBadgeView* _badge;
}

@property(nonatomic,retain) TTTabItem* tabItem;

- (id)initWithItem:(TTTabItem*)item tabBar:(TTTabBar*)tabBar style:(TTTabBarStyle)style;

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
