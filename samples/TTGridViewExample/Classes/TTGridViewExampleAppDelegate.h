//
//  TTGridViewExampleAppDelegate.h
//  TTGridViewExample
//
//  Created by Viridian Mobile Development Workstation on 5/18/12.
//  Copyright 2012 CME Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTGridViewExampleViewController;

@interface TTGridViewExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TTGridViewExampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TTGridViewExampleViewController *viewController;

@end

