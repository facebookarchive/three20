
#import "TextEditTestController.h"
#import <Three20/Three20.h>

@interface TestSearchSource : TTBasicDataSource <TTSearchSource>

@end

@implementation TestSearchSource

- (void)textField:(TTSearchTextField*)textField searchForText:(NSString*)text {
//  _items = [[NSMutableArray alloc] initWithObjects:
//    [[[TTActivityTableField alloc] initWithText:@"Searching..."] autorelease],
//    nil];

  [_items release];

  if (text.length) {
    _items = [[NSMutableArray alloc] initWithObjects:
      [[[TTTableField alloc] initWithText:@"Robert Anderson" href:@"fb://x"] autorelease],
      [[[TTTableField alloc] initWithText:@"Jim James" href:@"fb://x"] autorelease],
      nil];
  } else {
    _items = nil;
  }
  [textField updateResults];
}

- (NSString*)textField:(TTSearchTextField*)textField
    labelForRowAtIndexPath:(NSIndexPath*)indexPath {
  TTTableField* field = [self objectForRowAtIndexPath:indexPath];
  return field.text;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TextEditTestController

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController
//
- (void)loadView {
  self.view = [[[UIView alloc] init] autorelease];
  self.view.backgroundColor = [UIColor grayColor];
  
  _searchSource = [[TestSearchSource alloc] init];
  
  TTMenuTextField* textField = [[[TTMenuTextField alloc] initWithFrame:
    CGRectMake(0, 0, 320, 0)] autorelease];
  textField.searchSource = _searchSource;
  textField.visibleLineCount = 2;
  textField.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:textField];

  UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  label.text = @"To:";
  label.font = [UIFont systemFontOfSize:15];
  label.textColor = [UIColor colorWithWhite:0.7 alpha:1];
  [label sizeToFit];
  label.frame = CGRectInset(label.frame, -5, 0);
  textField.leftView = label;
  textField.leftViewMode = UITextFieldViewModeAlways;

  [textField addCellWithObject:@"johndoe1@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe2@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe3@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe4@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe5@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe6@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe7@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe8@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe9@mail.com" label:@"John Doe"];
//  [textField addCellWithObject:@"johndoe10@mail.com" label:@"John Doe"];

  [textField sizeToFit];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTSearchSource

@end
