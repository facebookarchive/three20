#import <Three20/Three20.h>

/*
 * a searchable model which can be configured with a 
 * loading and/or search time
 */
@interface MockAddressBook : NSObject <TTModel> {
  NSMutableArray* _delegates;
  NSMutableArray* _names;
  NSArray* _allNames;
  NSTimer* _fakeSearchTimer;
  NSTimeInterval _fakeSearchDuration;
  NSTimer* _fakeLoadingTimer;
  NSTimeInterval _fakeLoadingDuration;
}

@property(nonatomic,retain) NSArray* names;
@property(nonatomic) NSTimeInterval fakeSearchDuration;
@property(nonatomic) NSTimeInterval fakeLoadingDuration;

+ (NSMutableArray*)fakeNames;

- (id)initWithNames:(NSArray*)names;


- (void)search:(NSString*)text;

@end

@interface MockDataSource : TTSectionedDataSource {
  MockAddressBook* _addressBook;
}

@property(nonatomic,readonly) MockAddressBook* addressBook;

@end

@interface MockSearchDataSource : TTSectionedDataSource {
  MockAddressBook* _addressBook;
}

@property(nonatomic,readonly) MockAddressBook* addressBook;

- (id)initWithDuration:(NSTimeInterval)duration;

@end
