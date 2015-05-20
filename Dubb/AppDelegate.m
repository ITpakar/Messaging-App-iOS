//
//  AppDelegate.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <AWSiOSSDKv2/S3.h>
#import "DubbRootViewController.h"
#import "ChatViewController.h"
#import "ChatHistoryController.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "UserVoice.h"
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>

@interface AppDelegate () {
    CLLocationManager *locationManager;
    CLPlacemark *placeMark;
}
@property (nonatomic, strong) UIAlertView *alertView;
@end

@implementation AppDelegate

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [User currentUser];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self enableQuickBlox];
    [self enableUserVoice];
    
    #ifndef DEBUG
        [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;    
    #endif
    

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if( remoteNotification )
        [self openMessageFromNotification:remoteNotification];
    
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:awsAccessKey secretKey:awsSecretKey];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    
    [NRLogger setLogLevels:NRLogLevelALL];
    [NewRelicAgent startWithApplicationToken:kNewRelicToken];
    return YES;
}


#pragma mark - 
#pragma mark Google Analytics
-(void) enableGoogleAnalytics
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 30;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackId];
}


- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}


#pragma mark -
#pragma mark Facebook

 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark -
#pragma mark iRate

- (BOOL)iRateShouldPromptForRating
{
    if (!self.alertView)
    {
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Recommend Dubb" message:@"If you're enjoying DubbFreelancer (and we hope you are!), perhaps consider rating us 5 stars in the App Store." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate 5 Stars!", nil];
        
        [self.alertView show];
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        //ignore this version
        [iRate sharedInstance].declinedThisVersion = YES;
    }
    else if (buttonIndex == 1) // rate now
    {
        //mark as rated
        [iRate sharedInstance].ratedThisVersion = YES;
        
        //launch app store
        [[iRate sharedInstance] openRatingsPageInAppStore];
    }
    self.alertView = nil;
}


#pragma mark - 
#pragma mark QuickBlox

-(void) enableQuickBlox
{
    [QBApplication sharedApplication].applicationId = qbAppID;
    [QBConnection registerServiceKey:qbServiceKey];
    [QBConnection registerServiceSecret:qbServiceSecret];
    [QBSettings setAccountKey:qbAccountKey];
}

#pragma mark -
#pragma mark UserVoice

- (void)enableUserVoice{
    // Set this up once when your application launches
    UVConfig *config = [UVConfig configWithSite:@"dubb.uservoice.com"];
    config.forumId = 284535;
    // [config identifyUserWithEmail:@"email@example.com" name:@"User Name", guid:@"USER_ID");
    [UserVoice initialize:config];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if( [User currentUser].chatUser )
        [[ChatService instance] logout];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if( [User currentUser].chatUser )
        [[ChatService instance] logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if( [User currentUser].chatUser ){
        [[ChatService instance] loginWithUser:[User currentUser].chatUser completionBlock:^{
            
        }];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}


#pragma mark -
#pragma mark GeoLocation

-(void) updateUserLocation
{
    if( locationManager == nil ){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        User *currentUser = [User currentUser];
        currentUser.longitude = [NSNumber numberWithFloat: currentLocation.coordinate.longitude];
        currentUser.latitude = [NSNumber numberWithFloat: currentLocation.coordinate.latitude];
 
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLocationUpdated
                                                            object:nil userInfo:nil];
    }
    
    [locationManager stopUpdatingLocation];
    
    
    CLGeocoder* reverseGeocoder = [[CLGeocoder alloc] init];
    if (reverseGeocoder) {
        [reverseGeocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = [placemarks firstObject];
            if (placemark) {
                //Using blocks, get zip code
                User *user = [User currentUser];
                user.zipCode = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressZIPKey];
                user.countryCode = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCountryCodeKey];
                user.street = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStreetKey];
                user.city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
                user.state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
                user.country = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCountryKey];
            }
        }];
    }
    
}


- (void)registerForRemoteNotifications{
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    #else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    #endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    [self openMessageFromNotification:userInfo];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [QBRequest registerSubscriptionForDeviceToken:deviceToken successBlock:^(QBResponse *response, NSArray *subscriptions) {
        NSLog(@"Register for APNS");
    } errorBlock:nil];
}


#pragma mark Message Notification

//Message when App is foreground
-(void) didReceiveMessage:(QBChatMessage *)message {
    
    if( ![self.window.rootViewController isKindOfClass:[DubbRootViewController class]] ) return;
    
    DubbRootViewController *rootVC = (DubbRootViewController*)self.window.rootViewController;
    UINavigationController *navController = (UINavigationController *)rootVC.contentViewController;
    
    if( [[navController visibleViewController] isKindOfClass:[ChatViewController class]] ){  //ChatViewController is Opened now
        ChatViewController *chatVC = (ChatViewController*)[navController visibleViewController];
        if( chatVC.dialog.recipientID == message.senderID ) return;
    } else if ([[navController visibleViewController] isKindOfClass:[ChatHistoryController class]]){
        ChatHistoryController *chatHistoryVC = (ChatHistoryController*)[navController visibleViewController];
        [chatHistoryVC reloadChatHistory];
    }
    
    [self showNotification:message];
}

-(void) showNotification: (QBChatMessage*)message
{
    if( _notificationView == nil ){
        _notificationView = [[NotificationView alloc] init];
        _notificationView.delegate = self;
    }
    
    QBUUser *user = [User currentUser].usersAsDictionary[@(message.senderID)];
    if( user ){
        [self.window.rootViewController.view addSubview:_notificationView];
        [_notificationView hideNotification];
        NSString *notification = [NSString stringWithFormat:@"%@: %@", user.fullName, message.text];
        _notificationView.messageInfo = @{@"sender":@(message.senderID), @"receiver":@(message.recipientID)};
        [_notificationView showMessage:notification];
        return;
    }
    
    [QBRequest userWithID:message.senderID successBlock:^(QBResponse *response, QBUUser *user) {
        
        
        [self.window.rootViewController.view addSubview:_notificationView];
        NSString *notification = [NSString stringWithFormat:@"%@: %@", user.fullName, message.text];
        _notificationView.messageInfo = @{@"sender":@(message.senderID), @"receiver":@(message.recipientID)};
        [_notificationView showMessage:notification];
    } errorBlock:^(QBResponse *response) {
        
    }];
}

-(void) openMessage:(NSDictionary *)messageInfo
{
    [MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
    
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.occupantIDs = @[messageInfo[@"sender"]];
    chatDialog.type = QBChatDialogTypePrivate;
    [QBChat createDialog:chatDialog delegate:self];
}

//Message when app is background
-(void) openMessageFromNotification: (NSDictionary*) info
{
    if([User currentUser].chatUser){
        [QBChat updateDialogWithID:info[@"dialog_id"] extendedRequest:nil delegate:self];
    }
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result{
    
    [MBProgressHUD hideAllHUDsForView:self.window.rootViewController.view animated:NO];
    
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        // dialog created
        
        QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
        
        ChatViewController *chatController = (ChatViewController*)[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"chatController"];
        chatController.dialog = dialogRes.dialog;
        DubbRootViewController *rootVC = (DubbRootViewController*)self.window.rootViewController;
        UINavigationController *navController = (UINavigationController *)rootVC.contentViewController;
        [navController pushViewController:chatController animated:YES];
        
    }else{
    }
}

@end
