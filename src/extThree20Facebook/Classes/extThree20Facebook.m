//
// Copyright 2012 RIKSOF
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "extThree20Facebook.h"
#import "FbDate.h"
#import "FbDateTime.h"

@implementation extThree20Facebook 

@synthesize facebook;
@synthesize delegate;

static NSString *fbApplicationId = nil;
static NSString *fbApplicationToken = nil;

#pragma mark - Facebook Session

/**
 * Authorize this app to login to facebook.
 */
- (void) authorize:(NSArray *)permissions {
    [facebook authorize:permissions];
}

/**
 * Logout.
 */
- (void)logout {
    [facebook logout]; 
}

/**
 * Is the session valid?
 */
- (BOOL)isSessionValid {
    return [facebook isSessionValid];
}

/**
 * Extends the access token if needed.
 */
- (void)extendAccessTokenIfNeeded {
    [facebook extendAccessTokenIfNeeded];
}

/**
 * Handles the URL passed when control was given to application.
 */
- (BOOL)handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url];
}

#pragma mark - FBSessionDelegate Methods

/**
 * Remember authentication data
 */
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user has logged in successfully. We just pass this event
 * to our delegate.
 */
- (void)fbDidLogin {
    [self storeAuthData:facebook.accessToken expiresAt:facebook.expirationDate];
    
    if ( delegate != nil && [delegate respondsToSelector:@selector(fbDidLogin)] ) {
        [delegate fbDidLogin];
    }
}

/**
 * Called when token is extended. Just pass to our delegate.
 */
-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [self storeAuthData:accessToken expiresAt:expiresAt];
    
    if ( delegate != nil && [delegate respondsToSelector:@selector(fbDidExtendToken:expiresAt:)] ) {
        [delegate fbDidExtendToken:accessToken expiresAt:expiresAt];
    }
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    if ( delegate != nil && [delegate respondsToSelector:@selector(fbDidNotLogin:)] ) {
        [delegate fbDidNotLogin:cancelled];
    }
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    if ( delegate != nil && [delegate respondsToSelector:@selector(fbDidLogout)] ) {
        [delegate fbDidLogout];
    }
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    if ( delegate != nil && [delegate respondsToSelector:@selector(fbSessionInvalidated)] ) {
        [delegate fbSessionInvalidated];
    }
}

#pragma mark - FB Application Parameters

/**
 * Set the appplication id.
 */
+ (void)setFacebookApplicationId:(NSString *)appId {
    fbApplicationId = appId; 
}

/**
 * Get the application id.
 */
+ (NSString *)getFacebookApplicationId {
    return fbApplicationId;
}

/**
 * Set the application token.
 */
+ (void)setFacebookApplicationToken:(NSString *)token {
    fbApplicationToken = token; 
}

/**
 * Get the application token.
 */
+ (NSString *)getFacebookApplicationToken {
    return fbApplicationToken;
}

#pragma mark - Singleton

/**
 * We only have one instance of this model. It is the container of all
 * data for the app.
 */
+ (extThree20Facebook *)sharedInstance {
    
    static extThree20Facebook *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Do any other initialisation stuff here
        // Set the Value mappers for mapping xml values to local object values.
        TTValueMapper *mappers = [TTValueMapper sharedInstance];
        
        // Mapper for FbDateTime and FbDate
        [mappers addDocumentToObjectMapperForClass:[FbDateTime class] conversionBlock:
         ^(id object, NSString *property, __unsafe_unretained Class typeClass, id values, id value) {
             // Date formatter.
             NSDateFormatter *format = [[NSDateFormatter alloc] init];
             [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
             [object setValue:[format dateFromString:value] forKey:property];
         }];
        
        [mappers addObjectToDocumentMapperForClass:[FbDateTime class] conversionBlock:
         ^(id document, NSString *property, int mode, id value) {
             NSDateFormatter *format = [[NSDateFormatter alloc] init];
             [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
             NSString *date = [format stringFromDate:value];
             
             [((NSMutableDictionary *)document) setObject:date
                                                   forKey:property];
         }];
        
        [mappers addDocumentToObjectMapperForClass:[FbDate class] conversionBlock:
         ^(id object, NSString *property, __unsafe_unretained Class typeClass, id values, id value) {
             // Date formatter.
             NSDateFormatter *format = [[NSDateFormatter alloc] init];
             [format setDateFormat:@"mm/dd/yyyy"];
             [object setValue:[format dateFromString:value] forKey:property];
         }];
        
        [mappers addObjectToDocumentMapperForClass:[FbDate class] conversionBlock:
         ^(id document, NSString *property, int mode, id value) {
             NSDateFormatter *format = [[NSDateFormatter alloc] init];
             [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
             [format setDateFormat:@"mm/dd/yyyy"];
             NSString *date = [format stringFromDate:value];
             
             [((NSMutableDictionary *)document) setObject:date
                                                   forKey:property];
         }];
        
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize", fbApplicationId];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] &&
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            // Its not configured correctly.
            NSLog(@"Facebook Setup Error: Invalid or missing URL scheme. You cannot use the facebook client until you set up a valid URL scheme in your .plist.");
        } else {
            // The configuration is correct.
            sharedInstance = [[extThree20Facebook alloc] init];
            sharedInstance.facebook = [[Facebook alloc] initWithAppId:fbApplicationId andDelegate:sharedInstance];
            
            // Check and retrieve authorization information
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
                sharedInstance.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
                sharedInstance.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
            }
        }
        
    });
    return sharedInstance;
}

@end
