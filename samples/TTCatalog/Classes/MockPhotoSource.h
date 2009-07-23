#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  MockPhotoSourceNormal = 0,
  MockPhotoSourceDelayed = 1,
  MockPhotoSourceVariableCount = 2,
  MockPhotoSourceLoadError = 4,
} MockPhotoSourceType;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhotoSource : TTURLRequestModel <TTPhotoSource> {
  MockPhotoSourceType _type;
  NSString* _title;
  NSMutableArray* _photos;
  NSArray* _tempPhotos;
  NSTimer* _fakeLoadTimer;
}

- (id)initWithType:(MockPhotoSourceType)type title:(NSString*)title
      photos:(NSArray*)photos photos2:(NSArray*)photos2;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhoto : NSObject <TTPhoto> {
  id<TTPhotoSource> _photoSource;
  NSString* _thumbURL;
  NSString* _smallURL;
  NSString* _URL;
  CGSize _size;
  NSInteger _index;
  NSString* _caption;
}

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
      caption:(NSString*)caption;

@end
