//
//  Xcode324iOS41TestSuiteWorkaround.m
//
//  This source file provides a work-around to enable running unit tests
//  against the iPhone Simulator in Xcode 3.2.4 with iOS SDK 4.1.
//
//  This work-around is only needed when using Xcode 3.2.4 to target iOS 4.1.
//
//  Copyright 2010 Apple Inc. All rights reserved.
//

/*  Instructions:

 To use this workaround, add this source file to the Compile Sources
 build phase of your unit test bundle target.  It will be applied
 automatically before your tests are run.

 This is a workaround for an Xcode internal error that will be reported in
 the build log when attempting to run unit tests against the iPhone Simulator
 for iOS 4.1. This is due to a mismatch between what Xcode expects the date
 format in "Test Suite 'name' started at date" and "Test Suite 'name'
 finished at date." messages to look like, and how iOS 4.1
 implements  -[NSDate descriptionWithLocale:].

 The workaround works by exchanging the implementations of the
 -[SenTestRun startDate] and -[SenTestRun stopDate] methods for versions
 which return an NSDate subclass whose -descriptionWithLocale: method
 prints in a format compatible with what Xcode 3.2.4 expects.
*/

/*
 IMPORTANT:  The following Apple material is supplied to you by Apple Inc.
 (“Apple”) in consideration of your agreement to the following terms.  If you
 do not agree with these terms, do not use the Apple material.  In consideration
 of your agreement to abide by the following terms, and subject to these terms,
 Apple grants you a non-exclusive license, under Apple’s copyrights in this
 original Apple material, to use, reproduce, install, modify and redistribute
 the Apple materials, in their original form as provided by Apple or as modified
 by you; provided that if you modify the Apple materials, then you must not
 attribute them to Apple. Except as expressly stated in this notice, no other
 rights or licenses, express or implied, are granted by Apple herein.

 The Apple Materials are provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, OR ANY WARRANTY THAT THE APPLE MATERIALS WILL BE COMPATIBLE WITH
 FUTURE APPLE PRODUCTS, SOFTWARE OR SERVICES.  IN NO EVENT SHALL APPLE BE LIABLE
 FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES RELATING TO OR
 ARISING IN ANY WAY OUT OF THE USE OF THE APPLE MATERIALS BY YOU OR OTHERS,
 HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING
 NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF
 THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import <objc/runtime.h>

#if TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MAX_ALLOWED == __IPHONE_4_1)


// An NSDate subclass whose -descriptionWithLocale: is compatible with Xcode 3.2.4's unit test message parser.
@interface Xcode324iOS41TestSuiteWorkaroundDate : NSDate {
@private
    NSDate *_wrappedDate;
}

+ (id)workaroundDateWrappingDate:(NSDate *)wrappedDate;

@end


@implementation Xcode324iOS41TestSuiteWorkaroundDate

+ (id)workaroundDateWrappingDate:(NSDate *)wrappedDate {
    return [[[self alloc] initWithTimeIntervalSinceReferenceDate:[wrappedDate timeIntervalSinceReferenceDate]] autorelease];
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds {
    // required override (NSDate is a class cluster)
    self = [super init];
    if (self) {
        _wrappedDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:seconds];
    }

    return self;
}

- (void)dealloc {
    [_wrappedDate release];

    [super dealloc];
}

- (NSTimeInterval)timeIntervalSinceReferenceDate {
    // required override (NSDate is a class cluster)
    return [_wrappedDate timeIntervalSinceReferenceDate];
}

- (NSString *)descriptionWithLocale:(id)locale {
    // append 4 digits to the result of -descriptionWithLocale: for Xcode's unit test message parser
    NSString *originalDescription = [_wrappedDate descriptionWithLocale:locale];
    return [originalDescription stringByAppendingString:@" 0000"];
}

@end


// Methods added to SenTestRun that are swizzled in place of the existing methods to return instances of Xcode324iOS41TestSuiteWorkaroundDate instead of NSDate, so Xcode's unit test message parser gets output in the format it expects.
@interface SenTestRun (Xcode324iOS41TestSuiteWorkaroundMethods)
- (NSDate *)workaround_startDate;
- (NSDate *)workaround_stopDate;
@end


@implementation SenTestRun (Xcode324iOS41TestSuiteWorkaroundMethods)

+ (void)load {
    Class senTestRunClass = objc_getClass("SenTestRun");

    // Exchange the implementations of -[SenTestRun startDate] and -[SenTestRun workaround_startDate].
    Method originalStartDate = class_getInstanceMethod(senTestRunClass, @selector(startDate));
    Method workaroundStartDate = class_getInstanceMethod(senTestRunClass, @selector(workaround_startDate));
    method_exchangeImplementations(originalStartDate, workaroundStartDate);

    // Exchange the implementations of -[SenTestRun stopDate] and -[SenTestRun workaround_stopDate].
    Method originalStopDate = class_getInstanceMethod(senTestRunClass, @selector(stopDate));
    Method workaroundStopDate = class_getInstanceMethod(senTestRunClass, @selector(workaround_stopDate));
    method_exchangeImplementations(originalStopDate, workaroundStopDate);
}

- (NSDate *)workaround_startDate {
    // The below invokes the original -startDate due to the use of method_exchangeImplementatons in our +load.
    return [Xcode324iOS41TestSuiteWorkaroundDate workaroundDateWrappingDate:[self workaround_startDate]];
}

- (NSDate *)workaround_stopDate {
    // The below invokes the original -stopDate due to the use of method_exchangeImplementatons in our +load.
    return [Xcode324iOS41TestSuiteWorkaroundDate workaroundDateWrappingDate:[self workaround_stopDate]];
}

@end

#else
#warning "This workaround is only needed when using Xcode 3.2.4 to target iOS 4.1."
#endif
