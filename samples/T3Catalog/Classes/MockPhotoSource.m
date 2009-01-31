#import "MockPhotoSource.h"

@implementation MockPhotoSource

@synthesize title = _title;

- (id)initWithType:(MockPhotoSourceType)type photos:(NSArray*)photos photos2:(NSArray*)photos2 {
  if (self = [super init]) {
    _type = type;
    _photos = photos2 ? [[photos mutableCopy] retain] : [[NSMutableArray alloc] init];
    _tempPhotos = photos2 ? [photos2 retain] : [photos retain];

    for (int i = 0; i < _photos.count; ++i) {
      id<T3Photo> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        photo.photoSource = self;
        photo.index = i;
      }
    }

    if (_type & MockPhotoSourceDelayed || photos2) {
      _isInvalid = T3Invalid;
    } else {
      [self performSelector:@selector(fakeLoadReady)];
    }
  }
  return self;
}

- (void)dealloc {
  [_fakeLoadTimer invalidate];
  [_photos release];
  [_tempPhotos release];
  [super dealloc];
}

- (void)fakeLoadReady {
  _fakeLoadTimer = nil;
  _isInvalid = T3Valid;

  if (_type & MockPhotoSourceLoadError) {
    [_delegate photoSource:self loadLoadDidFailWithError:nil];
  } else {
    NSMutableArray* newPhotos = [NSMutableArray array];

    for (int i = 0; i < _photos.count; ++i) {
      id<T3Photo> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        [newPhotos addObject:photo];
      }
    }

    [newPhotos addObjectsFromArray:_tempPhotos];
    [_tempPhotos release];
    _tempPhotos = nil;

    [_photos release];
    _photos = [newPhotos retain];
    
    for (int i = 0; i < _photos.count; ++i) {
      id<T3Photo> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        photo.photoSource = self;
        photo.index = i;
      }
    }

    [_delegate photoSourceLoaded:self];
  }
  
  [_delegate release];
  _delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3Object

- (T3InvalidState)isInvalid {
  return _isInvalid;
}

- (void)setIsInvalid:(T3InvalidState)state {
  _isInvalid = state;
}

- (NSString*) viewURL {
  return nil;
}

+ (id<T3Object>)fromURL:(NSURL*)url {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3PhotoSource

- (NSUInteger)numberOfPhotos {
  if (_tempPhotos) {
    return _photos.count + (_type & MockPhotoSourceVariableCount ? 0 : _tempPhotos.count);
  } else {
    return _photos.count;
  }
}

- (NSUInteger)maxPhotoIndex {
  return _photos.count-1;
}

- (BOOL)loading {
  return !!_fakeLoadTimer;
}

- (id<T3Photo>)photoAtIndex:(NSUInteger)index {
  if (index < _photos.count) {
    id photo = [_photos objectAtIndex:index];
    if (photo == [NSNull null]) {
      return nil;
    } else {
      return photo;
    }
  } else {
    return nil;
  }
}

- (NSUInteger)indexOfPhoto:(id<T3Photo>)photo {
  return [_photos indexOfObject:photo];
}

- (void)loadPhotosFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
    delegate:(id<T3PhotoSourceDelegate>)delegate {
  _delegate = [delegate retain];
  [_delegate photoSourceLoading:self fromIndex:fromIndex toIndex:toIndex];

  _fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
    selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockPhoto

@synthesize photoSource = _photoSource, size = _size, index = _index;

- (id)initWithURL:(NSString*)aURL smallURL:(NSString*)aSmallURL size:(CGSize)aSize {
  if (self = [super init]) {
    _photoSource = nil;
    _url = [aURL copy];
    _smallURL = [aSmallURL copy];
    _thumbURL = [aSmallURL copy];
    _size = aSize;
    _index = NSIntegerMax;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_smallURL release];
  [_thumbURL release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3Object

- (T3InvalidState)isInvalid {
  return T3Valid;
}

- (void)setIsInvalid:(T3InvalidState)state {
}

- (NSString*)viewURL {
  return nil;
}

+ (id<T3Object>)fromURL:(NSURL*)url {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3Photo

- (NSString*)urlForVersion:(T3PhotoVersion)version {
  if (version == T3PhotoVersionLarge) {
    return _url;
  } else if (version == T3PhotoVersionMedium) {
    return _url;
  } else if (version == T3PhotoVersionSmall) {
    return _smallURL;
  } else if (version == T3PhotoVersionThumbnail) {
    return _thumbURL;
  } else {
    return nil;
  }
}

@end
