#import "ImageTableViewCell.h"

@implementation ImageTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    self.indentationLevel = 1;
    self.indentationWidth = 35;

		imageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    imageView.defaultImage = [UIImage imageNamed:@"DefaultAlbum.png"];
    [self addSubview:imageView];
	}
	return self;
}

- (void)dealloc {
  [imageView release];
	[super dealloc];
}

- (void)prepareForReuse {
  imageView.url = nil;
}

- (NSString*)imageURL {
  return imageView.url;
}

- (void)setImageURL:(NSString*)url {
  imageView.url = url;
}

@end
