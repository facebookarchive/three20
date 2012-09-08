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

#import "Facebook.h"
#import "FbUser.h"
#import "FbAccount.h"
#import "FbAchievement.h"
#import "FbScore.h"
#import "FbPage.h"
#import "FbLink.h"
#import "FbPost.h"

@interface extThree20Facebook : NSObject <FBSessionDelegate> {
    Facebook *facebook;
    id<FBSessionDelegate> delegate;
}

@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, strong) id<FBSessionDelegate> delegate;

- (BOOL)isSessionValid;
- (void)authorize:(NSArray *)permissions;
- (void)logout;
- (void)extendAccessTokenIfNeeded;
- (BOOL)handleOpenURL:(NSURL *)url;

+ (void)setFacebookApplicationId:(NSString *)appId;
+ (void)setFacebookApplicationToken:(NSString *)token;
+ (NSString *)getFacebookApplicationId;
+ (NSString *)getFacebookApplicationToken;
+ (extThree20Facebook *)sharedInstance;

@end
