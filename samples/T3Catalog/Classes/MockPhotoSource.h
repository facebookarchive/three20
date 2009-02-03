#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  MockPhotoSourceNormal = 0,
  MockPhotoSourceDelayed = 1,
  MockPhotoSourceVariableCount = 2,
  MockPhotoSourceLoadError = 4,
} MockPhotoSourceType;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhotoSource : NSObject <T3PhotoSource> {
  MockPhotoSourceType _type;
  id<T3PhotoSourceDelegate> _delegate;
  NSString* _title;
  NSMutableArray* _photos;
  NSArray* _tempPhotos;
  T3InvalidState _isInvalid;
  NSTimer* _fakeLoadTimer;
}

- (id)initWithType:(MockPhotoSourceType)type title:(NSString*)title
  photos:(NSArray*)photos photos2:(NSArray*)photos2;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhoto : NSObject<T3Photo> {
  id<T3PhotoSource> _photoSource;
  NSString* _thumbURL;
  NSString* _smallURL;
  NSString* _url;
  CGSize _size;
  NSInteger _index;
}

- (id)initWithURL:(NSString*)url smallURL:(NSString*)smallURL size:(CGSize)size;

@end
