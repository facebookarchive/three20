#import "Three20/TTThumbsTableViewCell.h"
#import "Three20/TTThumbView.h"
#import "Three20/TTPhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kSpacing = 4;
static CGFloat kThumbSize = 75;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsTableViewCell

@synthesize delegate = _delegate, photo = _photo;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)assignPhotoAtIndex:(int)index toView:(TTThumbView*)thumbView {
  id<TTPhoto> photo = [_photo.photoSource photoAtIndex:index];
  if (photo) {
    thumbView.url = [photo urlForVersion:TTPhotoVersionThumbnail];
    thumbView.hidden = NO;
  } else {
    thumbView.url = nil;
    thumbView.hidden = YES;
  }
}

- (void)thumbTouched:(TTThumbView*)thumbView {
  NSUInteger index;
  if (thumbView == _thumbView1) {
    index = _photo.index;
  } else if (thumbView == _thumbView2) {
    index = _photo.index + 1;
  } else if (thumbView == _thumbView3) {
    index = _photo.index + 2;
  } else if (thumbView == _thumbView4) {
    index = _photo.index + 3;
  }
  
  id<TTPhoto> photo = [_photo.photoSource photoAtIndex:index];
  [_delegate thumbsTableViewCell:self didSelectPhoto:photo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _photo = nil;
    _delegate = nil;
    _thumbView1 = [[TTThumbView alloc]
      initWithFrame:CGRectMake(kSpacing, 0, kThumbSize, kThumbSize)];
    [_thumbView1 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView1];

    _thumbView2 = [[TTThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*2+kThumbSize, 0, kThumbSize, kThumbSize)];
    [_thumbView2 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView2];

    _thumbView3 = [[TTThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*3+kThumbSize*2, 0, kThumbSize, kThumbSize)];
    [_thumbView3 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView3];

    _thumbView4 = [[TTThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*4+kThumbSize*3, 0, kThumbSize, kThumbSize)];
    [_thumbView4 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView4];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [_photo release];
  [_thumbView1 release];
  [_thumbView2 release];
  [_thumbView3 release];
  [_thumbView4 release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (id)object {
  return _photo;
}

- (void)setObject:(id)object {
  [self setPhoto:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhoto:(id<TTPhoto>)photo {
  if (_photo != photo) {
    [_photo release];
    _photo = [photo retain];

    if (!_photo) {
      _thumbView1.url = nil;
      _thumbView2.url = nil;
      _thumbView3.url = nil;
      _thumbView4.url = nil;
      return;
    }
    
    _thumbView1.url = [_photo urlForVersion:TTPhotoVersionThumbnail];
    [self assignPhotoAtIndex:_photo.index+1 toView:_thumbView2];
    [self assignPhotoAtIndex:_photo.index+1 toView:_thumbView2];
    [self assignPhotoAtIndex:_photo.index+2 toView:_thumbView3];
    [self assignPhotoAtIndex:_photo.index+3 toView:_thumbView4];
  }  
}

- (void)suspendLoading:(BOOL)suspended {
  [_thumbView1 suspendLoading:suspended];
  [_thumbView2 suspendLoading:suspended];
  [_thumbView3 suspendLoading:suspended];
  [_thumbView4 suspendLoading:suspended];
}

@end
