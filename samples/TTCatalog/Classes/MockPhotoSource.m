#import "MockPhotoSource.h"

@implementation MockPhotoSource

@synthesize title = _title;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)fakeLoadReady {
  _fakeLoadTimer = nil;

  if (_type & MockPhotoSourceLoadError) {
    [_delegates perform: @selector(model:didFailLoadWithError:)
                                withObject: self
                                withObject: nil];
  } else {
    NSMutableArray* newPhotos = [NSMutableArray array];

    for (int i = 0; i < _photos.count; ++i) {
      id<TTPhoto> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        [newPhotos addObject:photo];
      }
    }

    [newPhotos addObjectsFromArray:_tempPhotos];
    TT_RELEASE_SAFELY(_tempPhotos);

    [_photos release];
    _photos = [newPhotos retain];

    for (int i = 0; i < _photos.count; ++i) {
      id<TTPhoto> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        photo.photoSource = self;
        photo.index = i;
      }
    }

    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithType:(MockPhotoSourceType)type title:(NSString*)title photos:(NSArray*)photos
      photos2:(NSArray*)photos2 {
  if (self = [super init]) {
    _type = type;
    _title = [title copy];
    _photos = photos2 ? [photos mutableCopy] : [[NSMutableArray alloc] init];
    _tempPhotos = photos2 ? [photos2 retain] : [photos retain];
    _fakeLoadTimer = nil;

    for (int i = 0; i < _photos.count; ++i) {
      id<TTPhoto> photo = [_photos objectAtIndex:i];
      if ((NSNull*)photo != [NSNull null]) {
        photo.photoSource = self;
        photo.index = i;
      }
    }

    if (!(_type & MockPhotoSourceDelayed || photos2)) {
      [self performSelector:@selector(fakeLoadReady)];
    }
  }
  return self;
}

- (id)init {
  return [self initWithType:MockPhotoSourceNormal title:nil photos:nil photos2:nil];
}

- (void)dealloc {
  [_fakeLoadTimer invalidate];
  TT_RELEASE_SAFELY(_photos);
  TT_RELEASE_SAFELY(_tempPhotos);
  TT_RELEASE_SAFELY(_title);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoading {
  return !!_fakeLoadTimer;
}

- (BOOL)isLoaded {
  return !!_photos;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (cachePolicy & TTURLRequestCachePolicyNetwork) {
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];

    TT_RELEASE_SAFELY(_photos);
    _fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
      selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
  }
}

- (void)cancel {
  [_fakeLoadTimer invalidate];
  _fakeLoadTimer = nil;
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

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
  if (photoIndex < _photos.count) {
    id photo = [_photos objectAtIndex:photoIndex];
    if (photo == [NSNull null]) {
      return nil;
    } else {
      return photo;
    }
  } else {
    return nil;
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MockPhoto

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = _caption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size {
  return [self initWithURL:URL smallURL:smallURL size:size caption:nil];
}

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size
    caption:(NSString*)caption {
  if (self = [super init]) {
    _photoSource = nil;
    _URL = [URL copy];
    _smallURL = [smallURL copy];
    _thumbURL = [smallURL copy];
    _size = size;
    _caption = [caption copy];
    _index = NSIntegerMax;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_smallURL);
  TT_RELEASE_SAFELY(_thumbURL);
  TT_RELEASE_SAFELY(_caption);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

- (NSString*)URLForVersion:(TTPhotoVersion)version {
  if (version == TTPhotoVersionLarge) {
    return _URL;
  } else if (version == TTPhotoVersionMedium) {
    return _URL;
  } else if (version == TTPhotoVersionSmall) {
    return _smallURL;
  } else if (version == TTPhotoVersionThumbnail) {
    return _thumbURL;
  } else {
    return nil;
  }
}

@end
