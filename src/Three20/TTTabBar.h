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
