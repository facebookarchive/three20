//
//  NibDemoAppDelegate.h
//  NibDemo
//
//  Created by Don Skotch Vail on 4/3/10.
//  Copyright Brush The Dog Inc 2010. All rights reserved.
//

@interface NibDemoAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

