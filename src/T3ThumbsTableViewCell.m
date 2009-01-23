#import "Three20/T3ThumbsTableViewCell.h"
#import "Three20/T3ThumbView.h"
#import "Three20/T3PhotoSource.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kSpacing = 4;
static CGFloat kThumbSize = 75;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation T3ThumbsTableViewCell

@synthesize photo;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithFrame:frame reuseIdentifier:identifier]) {
    photo = nil;
    
    thumbView1 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing, 0, kThumbSize, kThumbSize)];
    [thumbView1 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:thumbView1];

    thumbView2 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*2+kThumbSize, 0, kThumbSize, kThumbSize)];
    [thumbView2 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:thumbView2];

    thumbView3 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*3+kThumbSize*2, 0, kThumbSize, kThumbSize)];
    [thumbView3 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:thumbView3];

    thumbView4 = [[T3ThumbView alloc]
      initWithFrame:CGRectMake(kSpacing*4+kThumbSize*3, 0, kThumbSize, kThumbSize)];
    [thumbView4 addTarget:self action:@selector(thumbTouched:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:thumbView4];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)dealloc {
  [photo release];
  [thumbView1 release];
  [thumbView2 release];
  [thumbView3 release];
  [thumbView4 release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)assignPhotoAtIndex:(int)index toView:(T3ThumbView*)thumbView {
  id<T3Photo> thePhoto = [photo.photoSource photoAtIndex:index];
  if (thePhoto) {
    thumbView.url = thePhoto.thumbURL;
    thumbView.hidden = NO;
  } else {
    thumbView.url = nil;
    thumbView.hidden = YES;
  }
}

- (void)thumbTouched:(T3ThumbView*)thumbView {
  NSUInteger index;
  if (thumbView == thumbView1) {
    index = photo.index;
  } else if (thumbView == thumbView2) {
    index = photo.index + 1;
  } else if (thumbView == thumbView3) {
    index = photo.index + 2;
  } else if (thumbView == thumbView4) {
    index = photo.index + 3;
  }
  
  id<T3Photo> thePhoto = [photo.photoSource photoAtIndex:index];
  UITableView* tableView = (UITableView*)self.superview;
  if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectPhoto:)]) {
    [tableView.delegate performSelector:@selector(tableView:didSelectPhoto:)
      withObject:tableView withObject:thePhoto];    
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPhoto:(id<T3Photo>)aPhoto {
  if (photo != aPhoto) {
    [photo release];
    photo = [aPhoto retain];
    if (!photo) {
      thumbView1.url = nil;
      thumbView2.url = nil;
      thumbView3.url = nil;
      thumbView4.url = nil;
      return;
    }
    
    thumbView1.url = photo.thumbURL;
    [self assignPhotoAtIndex:photo.index+1 toView:thumbView2];
    [self assignPhotoAtIndex:photo.index+1 toView:thumbView2];
    [self assignPhotoAtIndex:photo.index+2 toView:thumbView3];
    [self assignPhotoAtIndex:photo.index+3 toView:thumbView4];
  }  
}

- (void)pauseLoading:(BOOL)paused {
  [thumbView1 pauseLoading:paused];
  [thumbView2 pauseLoading:paused];
  [thumbView3 pauseLoading:paused];
  [thumbView4 pauseLoading:paused];
}

@end
