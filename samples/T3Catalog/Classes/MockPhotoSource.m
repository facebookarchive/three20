#import "MockPhotoSource.h"

@implementation MockPhotoSource

@synthesize title = _title;

- (id)initWithType:(MockPhotoSourceType)type title:(NSString*)title photos:(NSArray*)photos
    photos2:(NSArray*)photos2 {
  if (self = [super init]) {
    _type = type;
    _delegates = [[NSMutableArray alloc] init];
    
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
      _isInvalid = TTInvalid;
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

- (void)fakeLoadReady {
  _fakeLoadTimer = nil;
  _isInvalid = TTValid;

  if (_type & MockPhotoSourceLoadError) {
    [_request.delegate request:_request didFailWithError:nil];

    for (id<TTPhotoSourceDelegate> delegate in _delegates) {
      [delegate photoSource:self didFailWithError:nil];
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

    [_request.delegate request:_request loadedData:nil media:nil];

    for (id<TTPhotoSourceDelegate> delegate in _delegates) {
      [delegate photoSourceLoaded:self];
    }
  }
  
  [_request release];
  _request = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTObject

- (TTInvalidState)isInvalid {
  return _isInvalid;
}

- (void)setIsInvalid:(TTInvalidState)state {
  _isInvalid = state;
}

- (NSString*) viewURL {
  return nil;
}

+ (id<TTObject>)fromURL:(NSURL*)url {
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

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

- (BOOL)loading {
  return !!_fakeLoadTimer;
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

- (void)loadPhotos:(TTURLRequest*)request fromIndex:(NSInteger)fromIndex
    toIndex:(NSInteger)toIndex {
  if (request.cachePolicy & TTURLRequestCachePolicyNetwork) {
    _request = [request retain];
    [_request.delegate requestLoading:_request];
    
    for (id<TTPhotoSourceDelegate> delegate in _delegates) {
      [delegate photoSourceLoading:self];
    }
    
    _fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
      selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
  }
}

- (void)addDelegate:(id<TTPhotoSourceDelegate>)delegate {
  [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<TTPhotoSourceDelegate>)delegate {
  [_delegates removeObject:delegate];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockPhoto

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = _caption;

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
// TTObject

- (TTInvalidState)isInvalid {
  return TTValid;
}

- (void)setIsInvalid:(TTInvalidState)state {
}

- (NSString*)viewURL {
  return nil;
}

+ (id<TTObject>)fromURL:(NSURL*)url {
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
