//
//  UIDeviceAdditions.m
//  Three20UICommon
//
//  Created by Matej Ornest on 5.10.10.
//  Copyright 2010 Matej Ornest. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import "UIDeviceAdditions.h"

@implementation UIDevice (TTCategory)

- (NSString *) deviceType {
	
	size_t strSize;

	sysctlbyname("hw.machine", NULL, &strSize, NULL, 0); 
	
	char *deviceID = malloc(strSize);
	
	sysctlbyname("hw.machine", deviceID, &strSize, NULL, 0);
	
	NSString *deviceType = [NSString stringWithCString: deviceID encoding: NSUTF8StringEncoding];
	
	free(deviceID);
	
	return deviceType;
}

- (NSString *) osRelease {
	
	size_t strSize;
	
	sysctlbyname("kern.osrelease", NULL, &strSize, NULL, 0); 
	
	char *osRelease = malloc(strSize);
	
	sysctlbyname("kern.osrelease", osRelease, &strSize, NULL, 0);
	
	NSString *osType = [NSString stringWithCString: osRelease encoding: NSUTF8StringEncoding];
	
	free(osRelease);
	
	return osType;
}

@end
