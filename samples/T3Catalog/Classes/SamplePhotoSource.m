#import "SamplePhotoSource.h"

@implementation SamplePhotoSource

@synthesize title;

- (id)initWithPhotos:(NSArray*)aPhotos delayed:(BOOL)delayed {
  if (self = [super init]) {
    tempPhotos = [aPhotos retain];

    if (0 && delayed) {
      isInvalid = T3Invalid;
    } else {
      [self performSelector:@selector(fakeLoadReady)];
    }
  }
  return self;
}

- (void)dealloc {
  [fakeLoadTimer invalidate];
  [photos release];
  [tempPhotos release];
  [super dealloc];
}

- (void)fakeLoadReady {
  fakeLoadTimer = nil;
  isInvalid = T3Valid;

  photos = [[NSMutableArray alloc] initWithArray:tempPhotos];
  [tempPhotos release];
  tempPhotos = nil;
  
  for (int i = 0; i < photos.count; ++i) {
    id<T3Photo> photo = [photos objectAtIndex:i];
    photo.photoSource = self;
    photo.index = i;
  }

  [delegate photoSourceLoaded:self];
  [delegate release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3Object

- (T3InvalidState)isInvalid {
  return isInvalid;
}

- (void)setIsInvalid:(T3InvalidState)aState {
  isInvalid = aState;
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
  return photos.count;
}

- (NSUInteger)maxPhotoIndex {
  return photos.count-1;
}

- (BOOL)loading {
  return !!fakeLoadTimer;
}

- (id<T3Photo>)photoAtIndex:(NSUInteger)index {
  if (index < photos.count) {
    return [photos objectAtIndex:index];
  } else {
    return nil;
  }
}

- (NSUInteger)indexOfPhoto:(id<T3Photo>)photo {
  return [photos indexOfObject:photo];
}

- (void)loadPhotosFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
    delegate:(id<T3PhotoSourceDelegate>)aDelegate {
  delegate = [aDelegate retain];
  [delegate photoSourceLoading:self fromIndex:fromIndex toIndex:toIndex];

  fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
    selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SamplePhoto

@synthesize photoSource, thumbURL, smallURL, url, size, index;

- (id)initWithURL:(NSString*)aURL smallURL:(NSString*)aSmallURL size:(CGSize)aSize {
  if (self = [super init]) {
    photoSource = nil;
    url = [aURL copy];
    smallURL = [aSmallURL copy];
    thumbURL = [aSmallURL copy];
    size = aSize;
    index = NSIntegerMax;
  }
  return self;
}

- (void)dealloc {
  [url release];
  [smallURL release];
  [thumbURL release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3Object

- (T3InvalidState)isInvalid {
  return T3Valid;
}

- (void)setIsInvalid:(T3InvalidState)aState {
}

- (NSString*) viewURL {
  return nil;
}

+ (id<T3Object>)fromURL:(NSURL*)url {
  return nil;
}

@end
