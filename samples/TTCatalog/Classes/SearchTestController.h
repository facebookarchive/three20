#import <Three20/Three20.h>

@protocol SearchTestControllerDelegate;
@class MockDataSource;

@interface SearchTestController : TTTableViewController <TTSearchTextFieldDelegate> {
  id<SearchTestControllerDelegate> _delegate;
}

@property(nonatomic,assign) id<SearchTestControllerDelegate> delegate;

@end

@protocol SearchTestControllerDelegate <NSObject>

- (void)searchTestController:(SearchTestController*)controller didSelectObject:(id)object;

@end
