#import "MockPhotoSource.h"

@implementation MockPhotoSource

@synthesize title = _title;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)fakeLoadReady {
  _fakeLoadTimer = nil;
  _loadedTime = [[NSDate date] retain];

  if (_type & MockPhotoSourceLoadError) {
    for (id<TTPhotoSourceDelegate> delegate in _delegates) {
      [delegate photoSource:self didFailLoadWithError:nil];
    }
  } else {
    NSMutableArray* newPhotos = [NSMutableArray array];

    for (int i = 0; i < _photos.count; ++i) {
      id<TTPhoto> photo = [_photos objectAtIndex:i];
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
      id<TTPhoto> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        photo.photoSource = self;
        photo.index = i;
      }
    }

    for (id<TTPhotoSourceDelegate> delegate in _delegates) {
      [delegate photoSourceDidFinishLoad:self];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithType:(MockPhotoSourceType)type title:(NSString*)title photos:(NSArray*)photos
    photos2:(NSArray*)photos2 {
  if (self = [super init]) {
    _type = type;
    _delegates = nil;
    _loadedTime = nil;
    
    self.title = title;
    _photos = photos2 ? [[photos mutableCopy] retain] : [[NSMutableArray alloc] init];
    _tempPhotos = photos2 ? [photos2 retain] : [photos retain];

    for (int i = 0; i < _photos.count; ++i) {
      id<TTPhoto> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        photo.photoSource = self;
        photo.index = i;
      }
    }

    if (_type & MockPhotoSourceDelayed || photos2) {
    } else {
      [self performSelector:@selector(fakeLoadReady)];
    }
  }
  return self;
}

- (void)dealloc {
  [_fakeLoadTimer invalidate];
  [_delegates release];
  [_photos release];
  [_tempPhotos release];
  [_title release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPersistable

- (NSString*)viewURL {
  return nil;
}

+ (id<TTPersistable>)fromURL:(NSURL*)url {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLoadable

- (NSDate*)loadedTime {
  return _loadedTime;
}

- (BOOL)isLoading {
  return !!_fakeLoadTimer;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isLoaded {
  return !!_loadedTime;
}

- (BOOL)isEmpty {
  return NO;
}

- (void)invalidate:(BOOL)erase {
}

- (void)cancel {
  [_fakeLoadTimer invalidate];
  _fakeLoadTimer = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = TTCreateNonRetainingArray();
  }
  return _delegates;
}

- (NSInteger)numberOfPhotos {
  if (_tempPhotos) {
    return _photos.count + (_type & MockPhotoSourceVariableCount ? 0 : _tempPhotos.count);
  } else {
    return _photos.count;
  }
}

- (NSInteger)maxPhotoIndex {
  return _photos.count-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)index {
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

- (void)loadPhotosFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
    cachePolicy:(TTURLRequestCachePolicy)cachePolicy {
  if (cachePolicy & TTURLRequestCachePolicyNetwork) {
    for (id<TTPhotoSourceDelegate> delegate in _delegates) {
      [delegate photoSourceDidStartLoad:self];
    }
    
    _fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
      selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockPhoto

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = _caption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)url smallURL:(NSString*)smallURL size:(CGSize)size {
  return [self initWithURL:url smallURL:smallURL size:size caption:nil];
}

- (id)initWithURL:(NSString*)url smallURL:(NSString*)smallURL size:(CGSize)size
    caption:(NSString*)caption {
  if (self = [super init]) {
    _photoSource = nil;
    _url = [url copy];
    _smallURL = [smallURL copy];
    _thumbURL = [smallURL copy];
    _size = size;
    _caption = [caption copy];
    _index = NSIntegerMax;
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_smallURL release];
  [_thumbURL release];
  [_caption release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPersistable

- (NSString*)viewURL {
  return nil;
}

+ (id<TTPersistable>)fromURL:(NSURL*)url {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

- (NSString*)urlForVersion:(TTPhotoVersion)version {
  if (version == TTPhotoVersionLarge) {
    return _url;
  } else if (version == TTPhotoVersionMedium) {
    return _url;
  } else if (version == TTPhotoVersionSmall) {
    return _smallURL;
  } else if (version == TTPhotoVersionThumbnail) {
    return _thumbURL;
  } else {
    return nil;
  }
}

@end
