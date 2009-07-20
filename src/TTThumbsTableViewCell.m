#import "Three20/TTThumbsTableViewCell.h"
#import "Three20/TTThumbView.h"
#import "Three20/TTPhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kSpacing = 4;
static CGFloat kDefaultThumbSize = 75;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTThumbsTableViewCell

@synthesize delegate = _delegate, photo = _photo, thumbSize = _thumbSize,
           thumbOrigin = _thumbOrigin;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)assignPhotoAtIndex:(int)index toView:(TTThumbView*)thumbView {
  id<TTPhoto> photo = [_photo.photoSource photoAtIndex:index];
  if (photo) {
    thumbView.thumbURL = [photo URLForVersion:TTPhotoVersionThumbnail];
    thumbView.hidden = NO;
  } else {
    thumbView.thumbURL = nil;
    thumbView.hidden = YES;
  }
}

- (void)thumbTouched:(TTThumbView*)thumbView {
  NSUInteger index = 0;
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

- (void)layoutThumbViews {
  CGRect thumbFrame = CGRectMake(self.thumbOrigin.x, self.thumbOrigin.y,
                                 self.thumbSize, self.thumbSize);
  _thumbView1.frame = thumbFrame;
  
  thumbFrame.origin.x = self.thumbOrigin.x + kSpacing + self.thumbSize;
  _thumbView2.frame = thumbFrame;
  
  thumbFrame.origin.x = self.thumbOrigin.x + 2*kSpacing + 2*self.thumbSize;
  _thumbView3.frame = thumbFrame;
  
  thumbFrame.origin.x = self.thumbOrigin.x + 3*kSpacing + 3*self.thumbSize;
  _thumbView4.frame = thumbFrame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _photo = nil;
    _delegate = nil;
    _thumbSize = kDefaultThumbSize;
    _thumbOrigin = CGPointMake(kSpacing, 0);

    _thumbView1 = [[TTThumbView alloc] init];
    [_thumbView1 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView1];

    _thumbView2 = [[TTThumbView alloc] init];
    [_thumbView2 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView2];

    _thumbView3 = [[TTThumbView alloc] init];
    [_thumbView3 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView3];

    _thumbView4 = [[TTThumbView alloc] init];
    [_thumbView4 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView4];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_photo);
  TT_RELEASE_SAFELY(_thumbView1);
  TT_RELEASE_SAFELY(_thumbView2);
  TT_RELEASE_SAFELY(_thumbView3);
  TT_RELEASE_SAFELY(_thumbView4);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  [self layoutThumbViews];
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

- (void)setThumbSize:(CGFloat)thumbSize {
  _thumbSize = thumbSize;
  [self setNeedsLayout];
}

- (void)setThumbOrigin:(CGPoint)thumbOrigin {
  _thumbOrigin = thumbOrigin;
  [self setNeedsLayout];  
}

- (void)setPhoto:(id<TTPhoto>)photo {
  if (_photo != photo) {
    [_photo release];
    _photo = [photo retain];

    if (!_photo) {
      _thumbView1.thumbURL = nil;
      _thumbView2.thumbURL = nil;
      _thumbView3.thumbURL = nil;
      _thumbView4.thumbURL = nil;
      return;
    }
    
    _thumbView1.thumbURL = [_photo URLForVersion:TTPhotoVersionThumbnail];
    [self assignPhotoAtIndex:_photo.index+1 toView:_thumbView2];
    [self assignPhotoAtIndex:_photo.index+2 toView:_thumbView3];
    [self assignPhotoAtIndex:_photo.index+3 toView:_thumbView4];
  }  
}

- (void)suspendLoading:(BOOL)suspended {
  [_thumbView1 suspendLoadingImages:suspended];
  [_thumbView2 suspendLoadingImages:suspended];
  [_thumbView3 suspendLoadingImages:suspended];
  [_thumbView4 suspendLoadingImages:suspended];
}

@end
