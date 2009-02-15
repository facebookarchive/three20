
#import "TextEditTestController.h"
#import <Three20/Three20.h>

@implementation TextEditTestController

- (void)dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  self.view = [[[UIView alloc] init] autorelease];
  self.view.backgroundColor = [UIColor grayColor];
  
  T3MenuTextField* textField = [[[T3MenuTextField alloc] initWithFrame:
    CGRectMake(10, 10, 300, 30)] autorelease];
  textField.searchSource = self;
  textField.visibleLineCount = 2;
  textField.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:textField];

  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];
  [textField addCellWithObject:@"johndoe@mail.com" label:@"John Doe"];

  [textField sizeToFit];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// T3SearchSource

@end
