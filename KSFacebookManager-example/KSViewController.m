//
//  KSViewController.m
//  KSFacebookManager
//
//  Created by Shintaro Kaneko on 4/5/14.
//  Copyright (c) 2014 kaneshinth.com. All rights reserved.
//

#import "KSViewController.h"

#import <FacebookSDK/Facebook.h>
#import "KSFacebookManager.h"

@interface KSViewController ()
- (IBAction)handleFacebookButton:(id)sender;
- (IBAction)handleLogoutButton:(id)sender;
@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Refresh session for Facebook SDK.
    [[KSFacebookManager sharedManager] refreshSessionWithPermission];
}

- (IBAction)handleFacebookButton:(id)sender
{
    if ([KSFacebookManager sharedManager].session.state != FBSessionStateCreated) {
        [[KSFacebookManager sharedManager] refreshSessionWithPermission];
    }
    if (![KSFacebookManager sharedManager].session.isOpen) {
        [[KSFacebookManager sharedManager].session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.state == FBSessionStateOpen) {
                if (!error) {
                    NSString *accessToken = session.accessTokenData.accessToken;
                    [[[UIAlertView alloc] initWithTitle:@"Access token"
                                                message:accessToken
                                               delegate:nil
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:nil] show];
                } else {
                    NSLog(@"Failed Facebook: %@", error.description);
                }
            }
        }];
    }
}

- (IBAction)handleLogoutButton:(id)sender
{
    [[KSFacebookManager sharedManager] sessionCloseAndClearTokenInformation];
}

@end
