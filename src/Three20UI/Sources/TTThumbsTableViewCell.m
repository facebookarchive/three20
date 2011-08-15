//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/TTThumbsTableViewCell.h"

// UI
#import "Three20UI/TTThumbView.h"
#import "Three20UI/TTThumbsTableViewCellDelegate.h"
#import "Three20UI/TTPhotoVersion.h"
#import "Three20UI/TTPhotoSource.h"
#import "Three20UI/TTPhoto.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

static const CGFloat kSpacing = 4;
static const CGFloat kDefaultThumbSize = 75;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTThumbsTableViewCell

@synthesize photo       = _photo;
@synthesize thumbSize   = _thumbSize;
@synthesize thumbOrigin = _thumbOrigin;
@synthesize columnCount = _columnCount;
@synthesize delegate    = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
  if (self) {
    _thumbViews = [[NSMutableArray alloc] init];
    _thumbSize = kDefaultThumbSize;
    _thumbOrigin = CGPointMake(kSpacing, 0);

    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_photo);
  TT_RELEASE_SAFELY(_thumbViews);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)assignPhotoAtIndex:(int)photoIndex toView:(TTThumbView*)thumbView {
  id<TTPhoto> photo = [_photo.photoSource photoAtIndex:photoIndex];
  if (photo) {
    thumbView.thumbURL = [photo URLForVersion:TTPhotoVersionThumbnail];
    thumbView.hidden = NO;

  } else {
    thumbView.thumbURL = nil;
    thumbView.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbTouched:(TTThumbView*)thumbView {
  NSUInteger thumbViewIndex = [_thumbViews indexOfObject:thumbView];
  NSInteger offsetIndex = _photo.index + thumbViewIndex;

  id<TTPhoto> photo = [_photo.photoSource photoAtIndex:offsetIndex];
  [_delegate thumbsTableViewCell:self didSelectPhoto:photo];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutThumbViews {
  CGRect thumbFrame = CGRectMake(self.thumbOrigin.x, self.thumbOrigin.y,
                                 self.thumbSize, self.thumbSize);

  for (TTThumbView* thumbView in _thumbViews) {
    thumbView.frame = thumbFrame;
    thumbFrame.origin.x += kSpacing + self.thumbSize;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  [self layoutThumbViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
  return _photo;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  [self setPhoto:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setThumbSize:(CGFloat)thumbSize {
  _thumbSize = thumbSize;
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setThumbOrigin:(CGPoint)thumbOrigin {
  _thumbOrigin = thumbOrigin;
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setColumnCount:(NSInteger)columnCount {
  if (_columnCount != columnCount) {
    for (TTThumbView* thumbView in _thumbViews) {
      [thumbView removeFromSuperview];
    }
    [_thumbViews removeAllObjects];

    _columnCount = columnCount;

    for (NSInteger i = _thumbViews.count; i < _columnCount; ++i) {
      TTThumbView* thumbView = [[[TTThumbView alloc] init] autorelease];
      [thumbView addTarget:self action:@selector(thumbTouched:)
                 forControlEvents:UIControlEventTouchUpInside];
      [self.contentView addSubview:thumbView];
      [_thumbViews addObject:thumbView];
      if (_photo) {
        [self assignPhotoAtIndex:_photo.index+i toView:thumbView];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhoto:(id<TTPhoto>)photo {
  if (_photo != photo) {
    [_photo release];
    _photo = [photo retain];

    if (!_photo) {
      for (TTThumbView* thumbView in _thumbViews) {
        thumbView.thumbURL = nil;
      }
      return;
    }

    NSInteger i = 0;
    for (TTThumbView* thumbView in _thumbViews) {
      [self assignPhotoAtIndex:_photo.index+i toView:thumbView];
      ++i;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoading:(BOOL)suspended {
  for (TTThumbView* thumbView in _thumbViews) {
    [thumbView suspendLoadingImages:suspended];
  }
}


@end
