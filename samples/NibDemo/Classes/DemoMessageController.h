//
//  DemoMessageController.h
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright 2010 Brush The Dog, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DemoMessageController : TTMessageController {
  UIView * mTitleView;

}

@property (nonatomic, retain) IBOutlet UIView * titleView;

@end
