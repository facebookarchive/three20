#import "Three20/Three20.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface SamplePhotoSource : NSObject <T3PhotoSource> {
  id<T3PhotoSourceDelegate> delegate;
  NSString* title;
  NSMutableArray* photos;
  NSArray* tempPhotos;
  T3InvalidState isInvalid;
  NSTimer* fakeLoadTimer;
}

- (id)initWithPhotos:(NSArray*)photos delayed:(BOOL)delayed;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface SamplePhoto : NSObject<T3Photo> {
  id<T3PhotoSource> photoSource;
  NSString* thumbURL;
  NSString* smallURL;
  NSString* url;
  CGSize size;
  NSInteger index;
}

- (id)initWithURL:(NSString*)url smallURL:(NSString*)smallURL size:(CGSize)size;

@end
