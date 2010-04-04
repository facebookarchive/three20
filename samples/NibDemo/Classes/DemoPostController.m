//
//  DemoPostController.m
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright 2010 Brush The Dog, Inc. All rights reserved.
//

#import "DemoPostController.h"


@implementation DemoPostController

@synthesize titleView = mTitleView;

- (void)dealloc {
    [super dealloc];
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.titleView)
    self.navigationItem.titleView = self.titleView;
  
  self.textView.text = @"notice that there is a  UISwitch in the nav bar that "
  "was loaded from a nib";
}

@end
