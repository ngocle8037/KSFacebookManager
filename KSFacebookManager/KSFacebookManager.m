// KSFacebookManager.m
//
// Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "KSFacebookManager.h"

#import <FacebookSDK/Facebook.h>

#define KSFacebookAppID \
    ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"])

#define KSFacebookAppPermissions \
    ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppPermissions"])

@interface KSFacebookManager ()
@property (readwrite, nonatomic, strong) NSArray *permissions;
@property (readwrite, nonatomic, strong) NSString *facebookAppID;
@end

@implementation KSFacebookManager {
    struct {
        unsigned int isFBSessionTokenCachingStrategy:1;
    } _fbFlags;
}

+ (instancetype)sharedManager
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[KSFacebookManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSAssert(KSFacebookAppID, @"Sets the FacebookAppID into info.plist.");
        NSAssert([KSFacebookAppID isKindOfClass:[NSString class]], @"Sets the FacebookAppID as the type of String.");
        [self setConfiguration:nil];
    }
    return self;
}

- (void)setConfiguration:(id<EXFacebookManagerConfiguration>)configuration
{
    _configuration = configuration;
    if ([self.configuration respondsToSelector:@selector(permissionsForFacebookManager:)]) {
        self.permissions = [self.configuration permissionsForFacebookManager:self];
    } else {
        NSArray *permissions = KSFacebookAppPermissions;
        self.permissions = permissions && permissions.count > 0 ? permissions : @[@"email"];
    }
    if ([self.configuration respondsToSelector:@selector(facebookAppIDForFacebookManager:)]) {
        self.facebookAppID = [self.configuration facebookAppIDForFacebookManager:self];
    } else {
        self.facebookAppID = KSFacebookAppID;
    }
    if ([self.configuration respondsToSelector:@selector(defaultFBSessionTokenCachingStrategyForFacebookManager:)]) {
        _fbFlags.isFBSessionTokenCachingStrategy = (bool)[self.configuration defaultFBSessionTokenCachingStrategyForFacebookManager:self];
    } else {
        _fbFlags.isFBSessionTokenCachingStrategy = 0;
    }
}

- (NSString *)URLScheme
{
    return [NSString stringWithFormat:@"fb%@", self.facebookAppID];
}

- (void)refreshSession
{
    self.session = [[FBSession alloc] init];
}

- (void)refreshSessionWithPermission
{
    if (_fbFlags.isFBSessionTokenCachingStrategy) {
        self.session = [[FBSession alloc] initWithAppID:self.facebookAppID
                                            permissions:self.permissions
                                        urlSchemeSuffix:[self URLScheme]
                                     tokenCacheStrategy:[FBSessionTokenCachingStrategy defaultInstance]];
    } else {
        self.session = [[FBSession alloc] initWithPermissions:self.permissions];
    }
}

- (void)applicationDidBecomeActive
{
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (void)applicationWillTerminate
{
    [self.session close];
}

- (BOOL)application:(__unused UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(__unused id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:self.session];
}

- (void)sessionCloseAndClearTokenInformation
{
    if (self.session.isOpen) {
        [self.session closeAndClearTokenInformation];
    }
}

@end
