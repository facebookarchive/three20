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

#import "HomeScreen.h"
#import "AppDelegate.h"
#import "FbModel.h"
#import "FbAccount.h"
#import "FbAchievement.h"

@implementation HomeScreen

#pragma mark - Authentication data

/**
 * Remember authentication data
 */
- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark - Remote Delegate

/**
 * Objects loaded successfully.
 */
- (void)remoteObject:(TTRemoteObject *)remoteObject didFinishLoadForRequest:(TTURLRequest *)request {
    FbModel *model = [FbModel sharedInstance];
    
    // If we just loaded the user, then load the users connections.
    if ( [remoteObject class] == [FbUser class] ) {
        model.myUser.accounts = [[FbConnection alloc] initWithConnector:model.myUser 
                                                            objectClass:[FbAccount class] 
                                                             connection:@"accounts"];
        [model.myUser.accounts registerDelegate:self];
        [model.myUser.accounts load];
        
        model.myUser.achievements = [[FbConnection alloc] initWithConnector:model.myUser
                                                                objectClass:[FbAchievement class]
                                                                 connection:@"achievements"];
        [model.myUser.achievements registerDelegate:self];
        [model.myUser.achievements load];
    } else {
        NSLog(@"%@", model.myUser.accounts);
    }
    
    
    // The data has been processed.
    [super remoteObject:remoteObject didFinishLoadForRequest:request];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    // Store the authentication data.
    FbModel *model = [FbModel sharedInstance];
    [self storeAuthData:model.facebook.accessToken expiresAt:model.facebook.expirationDate];
    [model.myUser load];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
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
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Initialize Facebook
        FbModel *model = [FbModel sharedInstance];
        model.facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
        
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
            model.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            model.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    FbModel *model = [FbModel sharedInstance];
    
    // Initialize permissions
    permissions = [[NSArray alloc] initWithObjects:@"offline_access", @"manage_pages", 
                   @"user_games_activity", @"user_activities", nil];
    
    // Get the logged in user.
    model.myUser = [[FbUser alloc] initWithId:@"me"];
    
    // We need to know when this user has loaded.
    [model.myUser registerDelegate:self];
    
    // Login if we are not logged in yet.
    if (![model.facebook isSessionValid]) {
        [model.facebook authorize:permissions];
    } else {
        // Load the user
        [model.myUser load];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
