#import <Three20/Three20.h>

//
//  TableDemo.h
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright Brush The Dog Inc 2010. All rights reserved.
//

@interface DemoTableViewController : TTTableViewController
{
	UIView *	mHeaderView;	
	UIView *	mFooterView;	
}

@property (nonatomic, retain) IBOutlet UIView * headerView;
@property (nonatomic, retain) IBOutlet UIView * footerView;

@end
