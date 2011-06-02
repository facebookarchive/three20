//
//  UIDeviceAdditions.h
//  Three20UICommon
//
//  Created by Matej Ornest on 5.10.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIDevice (TTCategory)

- (NSString *) deviceType;

- (NSString *) osRelease;

@end
