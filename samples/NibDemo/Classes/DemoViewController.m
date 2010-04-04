//
//  DemoViewController.m
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright 2010 Brush The Dog, Inc. All rights reserved.
//

#import "DemoViewController.h"


@implementation DemoViewController

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"DemoViewController";
}  

- (void)dealloc {
    [super dealloc];
}


@end
