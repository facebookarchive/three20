#import <Three20/Three20.h>

typedef enum {
  MenuPageNone,
  MenuPageBreakfast,
  MenuPageLunch,
  MenuPageDinner,
  MenuPageDessert,
  MenuPageAbout,
} MenuPage;

@interface MenuController : TTTableViewController {
  MenuPage _page;
}

@property(nonatomic) MenuPage page;

@end
