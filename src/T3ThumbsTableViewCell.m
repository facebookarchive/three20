#import "Three20/T3ThumbsTableViewCell.h"
#import "Three20/T3ThumbView.h"
#import "Three20/T3PhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kSpacing = 4;
static CGFloat kThumbSize = 75;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ThumbsTableViewCell

@synthesize photo = _photo;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    _photo = nil;
    
    _thumbView1 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing, 0, kThumbSize, kThumbSize)];
    [_thumbView1 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView1];

    _thumbView2 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*2+kThumbSize, 0, kThumbSize, kThumbSize)];
    [_thumbView2 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView2];

    _thumbView3 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*3+kThumbSize*2, 0, kThumbSize, kThumbSize)];
    [_thumbView3 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_thumbView3];

    _thumbView4 = [[T3ThumbView alloc]
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

- (void)assignPhotoAtIndex:(int)index toView:(T3ThumbView*)_thumbView {
  id<T3Photo> photo = [_photo.photoSource photoAtIndex:index];
  if (photo) {
    _thumbView.url = [photo urlForVersion:T3PhotoVersionThumbnail];
    _thumbView.hidden = NO;
  } else {
    _thumbView.url = nil;
    _thumbView.hidden = YES;
  }
}

- (void)thumbTouched:(T3ThumbView*)_thumbView {
  NSUInteger index;
  if (_thumbView == _thumbView1) {
    index = _photo.index;
  } else if (_thumbView == _thumbView2) {
    index = _photo.index + 1;
  } else if (_thumbView == _thumbView3) {
    index = _photo.index + 2;
  } else if (_thumbView == _thumbView4) {
    index = _photo.index + 3;
  }
  
  id<T3Photo> photo = [_photo.photoSource photoAtIndex:index];
  UITableView* tableView = (UITableView*)self.superview;
  if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectPhoto:)]) {
    [tableView.delegate performSelector:@selector(tableView:didSelectPhoto:)
      withObject:tableView withObject:photo];    
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhoto:(id<T3Photo>)photo {
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
    
    _thumbView1.url = [_photo urlForVersion:T3PhotoVersionThumbnail];
    [self assignPhotoAtIndex:_photo.index+1 toView:_thumbView2];
    [self assignPhotoAtIndex:_photo.index+1 toView:_thumbView2];
    [self assignPhotoAtIndex:_photo.index+2 toView:_thumbView3];
    [self assignPhotoAtIndex:_photo.index+3 toView:_thumbView4];
  }  
}

- (void)pauseLoading:(BOOL)paused {
  [_thumbView1 pauseLoading:paused];
  [_thumbView2 pauseLoading:paused];
  [_thumbView3 pauseLoading:paused];
  [_thumbView4 pauseLoading:paused];
}

@end
