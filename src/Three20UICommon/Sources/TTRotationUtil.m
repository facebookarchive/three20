//
//  TTRotationUtil.m
//  Three20UICommon
//
//  Created by J. George Smith on 5/1/14.
//
//

#import "TTRotationUtil.h"

////////////////////////////////////////////////////////////////////////////////
@implementation TTRotationUtil

+ (BOOL)shouldAutorotate {
    if ([TTRotationUtil isIPad]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSUInteger)supportedInterfaceOrientations {
    // Tara & Matt do not want landscape anywhere when running on a small screen.
    if ([TTRotationUtil isIPad]) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

+ (BOOL)isIPad {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            return YES;
        }
    }
    return NO;
}

@end
