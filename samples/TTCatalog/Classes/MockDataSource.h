#import <Three20/Three20.h>

@class TestAddressBook;

@interface MockDataSource : TTSectionedDataSource {
  TestAddressBook* _addressBook;
}

@end

@interface MockSearchDataSource : TTSectionedDataSource {
  TestAddressBook* _addressBook;
}

@end
