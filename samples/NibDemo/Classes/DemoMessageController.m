//
//  DemoMessageController.m
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright 2010 Brush The Dog, Inc. All rights reserved.
//

#import "DemoMessageController.h"


@implementation DemoMessageController

@synthesize titleView = mTitleView;

- (void)dealloc {
    [super dealloc];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"DemoMessageController";
  }
  return self;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.titleView)
    self.navigationItem.titleView = self.titleView;

  self.body = @"This class is loaded from a NIB. Notice that title view "
  "that is defined in the NIB file";
}

@end
