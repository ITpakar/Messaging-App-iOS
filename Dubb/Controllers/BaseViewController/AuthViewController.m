//
//  AuthViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 23/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "AuthViewController.h"
#import "DubbSignUpEmailViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AppDelegate.h"

@interface AuthViewController ()< GPPSignInDelegate, QBChatDelegate>

@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [((AppDelegate*)[UIApplication sharedApplication].delegate) updateUserLocation];
    [((AppDelegate*)[UIApplication sharedApplication].delegate) startLocationTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark Google+ Login

-(void) googlePlusLogin
{
    [[User currentUser] initialize];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.shouldFetchGoogleUserID = YES;
    
    signIn.clientID = kGoogleClientID;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    
    signIn.delegate = self;
    
    if( ![signIn trySilentAuthentication] )
        [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {

    if( !error ){
        GPPSignIn * signIn = [GPPSignIn sharedInstance];
        [self showProgress:@"Connecting..."];
        [self signUpWithSocial:kGoogleUser socialID:signIn.userID email:signIn.userEmail firstName:signIn.googlePlusUser.name.givenName lastName:signIn.googlePlusUser.name.familyName profileImageURL:signIn.googlePlusUser.image.url gender: signIn.googlePlusUser.gender];
        
    } else {
        [self showMessage:@"Something went wrong with Google+"];
    }
}

#pragma mark -
#pragma mark Facebook Login

-(void) facebookLogin
{
    // If the session state is any of the two "open" states when the button is clicked
    [[User currentUser] initialize];
    
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended ||
        FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded ) {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"] allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self FBSessionStateChanged:session state:status error:error];
        }];
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             [self FBSessionStateChanged:session state:state error:error];
             
         }];
    }
}


-(void) FBSessionStateChanged:(FBSession*)session state:(FBSessionState) state error:(NSError*)error
{
    if( !error && state == FBSessionStateOpen ){
        [self getFacebookUserInfo];
    } else if( error ) {
        [self showMessage:@"Something went wrong with Facebook login"];
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}


-(void) getFacebookUserInfo
{
    
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    FBRequest *request = [FBRequest requestForMe];
    
    
    if (FBSession.activeSession.isOpen) {
        [self showProgress:@"Connecting..."];
        [connection addRequest:request
             completionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 NSString *profileURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", user.objectID];
                
                 [self signUpWithSocial:kFacebookUser socialID:user.objectID email:user[@"email"] firstName:user.first_name lastName:user.last_name profileImageURL:profileURL gender:user[@"gender"]];

             } else {
                 [self hideProgress];
                 [self showMessage:@"Something went wrong with Facebook"];
             }
             
         }];
        
        [connection start];
        
    } else {
        [self showMessage:@"Facebook session expires"];
    }
}



#pragma mark -
#pragma mark Register User

-(void) signUpWithSocial : (NSInteger) userType
                 socialID:(NSString*)userid
                    email:(NSString*)email
                firstName:(NSString*)fname
                 lastName:(NSString*)lname
          profileImageURL:(NSString*)url
                   gender:(NSString*)gender
{
    UIImage *profileImage = nil;
    User *currentUser = [User currentUser];
    NSDictionary *params;
    
    if( ![url isEqualToString:@""] ){
        NSData *data  = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        profileImage = [[UIImage alloc] initWithData:data];
        
    }
    [self hideProgress];
    
    //User Profile
    
    
    currentUser.firstName = fname;
    currentUser.lastName = lname;
    currentUser.profileImage = profileImage;
    currentUser.gender = gender;
    currentUser.email = email;
    
    if( userType == kFacebookUser ){
        currentUser.fbID = userid;
        
        params = @{ @"email":email, @"password":qbDefaultPassword, @"first":fname, @"last":lname, @"lat":@"55.7502", @"long":@"37.6168", @"facebook_token":userid, @"gender":gender, @"image": url};
        
    } else {
        currentUser.gpID = userid;
        params = @{ @"email":email, @"password":qbDefaultPassword, @"first":fname, @"last":lname, @"lat":@"55.7502", @"long":@"37.6168", @"gplus_token":userid, @"image": url};
    }
                             
    if( currentUser.latitude.intValue + currentUser.longitude.intValue != 0 )
        [self registerUserToDubb:params];
    else
        [self showMessage:@"Please enable location services at phone settings."];
}

-(int) registerUserToDubb : (NSDictionary*) params
{
    [self showProgress:@"Connecting..."];
    [self.backend registerWithSocial:params CompletionHandler:^(NSDictionary *result) {
        [self hideProgress];
        if( result ){
            User *user = [User initialize:result[@"response"]];
            
            [self hideProgress];
            if (user.username != nil && ![user.username isEqualToString:@""]){
                if (user.quickbloxID && ![user.quickbloxID isEqualToString:@""]){
                    [self showProgress:@"Logging in..."];
                    [self loginToQuickBlox];
                } else {
                    [self showProgress:@"Registering a user..."];
                    [self registerUserToQuickBlox];
                }
            } else {
                DubbSignUpEmailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpWithEmailViewController"];
                vc.userId = result[@"response"][@"id"];
                vc.userInfo = params;
                [self.navigationController pushViewController: vc animated:YES];
            }
            
        } else {
            [self showMessage:@"Registering a user fails"];
            [self hideProgress];
        }
    }];
    
    return -1;
}

-(int) updateUserToDubbWithUserID: (NSString *)userID
                           params: (NSDictionary*) params
{
    [self showProgress:@"Connecting..."];
    [self.backend updateUser:userID Parameters:params CompletionHandler:^(NSDictionary *result) {
        
        [self hideProgress];
        if (result) {
        
            User *user = [User initialize:result[@"response"]];
            
            if (user.quickbloxID && ![user.quickbloxID isEqualToString:@""]){
                [self showProgress:@"Logging in..."];
                [self loginToQuickBlox];
            } else {
                [self showProgress:@"Registering a user..."];
                [self registerUserToQuickBlox];
            }
            
        }
        
    }];
    return -1;
}

-(void) registerUserWithUsername : (NSDictionary*)params
{
    [self showProgress:@"Connecting..."];
    [self.backend updateUser:[User currentUser].userID Parameters:params CompletionHandler:^(NSDictionary *result) {
        if( result ){
            User *user = [User initialize:result[@"response"]];
            [self hideProgress];
            if (user.quickbloxID && ![user.quickbloxID isEqualToString:@""]){
                [self showProgress:@"Logging in..."];
                [self loginToQuickBlox];
            } else {
                [self showProgress:@"Registering a user..."];
                [self registerUserToQuickBlox];
            }
        } else {
            [self showMessage:@"Registering a user fails"];
            [self hideProgress];
        }
    }];
}


-(BOOL) registerUserToQuickBlox
{
     //QuickBlox
     
     [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
         QBUUser *user = [QBUUser user];
         user.login = [User currentUser].email;
         user.password = qbDefaultPassword;
         user.fullName = [NSString stringWithFormat:@"%@ %@", [User currentUser].firstName, [User currentUser].lastName];
         user.externalUserID = [[User currentUser].userID integerValue];
         user.customData = [User currentUser].username;
         
         [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
             [User currentUser].quickbloxID = [NSString stringWithFormat:@"%d", (int)user.ID];
             NSMutableDictionary *paramsToBeUpdated = [NSMutableDictionary dictionaryWithDictionary:@{@"quickblox_id":@(user.ID)}];
             if ([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_DEVICE_TOKEN])
                 [self.backend registerDeviceToken:[[NSUserDefaults standardUserDefaults] stringForKey:DEFAULTS_DEVICE_TOKEN] forUser:[User currentUser].userID CompletionHandler:nil];
             
             [self.backend updateUser:[User currentUser].userID Parameters:@{@"quickblox_id":@(user.ID)} CompletionHandler:nil];
             
             [QBRequest logInWithUserLogin:user.login password:qbDefaultPassword successBlock:^(QBResponse *response, QBUUser *user) {
                 [User currentUser].chatUser = user;
                 [User currentUser].chatUser.password = qbDefaultPassword;
                 [[ChatService instance] loginWithUser:[User currentUser].chatUser completionBlock:nil];
                 
                 if( [User currentUser].profileImage ){
                     NSData *data = UIImagePNGRepresentation([User currentUser].profileImage);
                     
                     [QBRequest TUploadFile:data fileName:@"MyAvatar" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
                         
                         QBUUser *user = [QBUUser user];
                         user.ID = [[User currentUser].quickbloxID integerValue];
                         user.blobID = blob.ID;

                         [QBRequest updateUser:user successBlock:^(QBResponse *response, QBUUser *user) {
                             [self hideProgress];
                             [self onAuthenticationSuccess:YES];
                         } errorBlock:^(QBResponse *response) {
                             [self hideProgress];
                             [self onAuthenticationSuccess:YES];
                         }];
                         
                     } statusBlock:nil errorBlock:^(QBResponse *response) {
                         [self hideProgress];
                         [self onAuthenticationSuccess:YES];
                     }];
                 } else {
                     
                     [self hideProgress];
                     [self onAuthenticationSuccess:YES];
                 }
                 
             } errorBlock:^(QBResponse *response) {
                 [self hideProgress];
                 [self onAuthenticationSuccess:NO];
             }];
             
         } errorBlock:^(QBResponse *response) {
             [self hideProgress];
             [self onAuthenticationSuccess:NO];
         }];
         
     } errorBlock:^(QBResponse *response) {
         NSLog(@"Error: %@", response);
         [self hideProgress];
         [self onAuthenticationSuccess:NO];
     }];
    return NO;
}


#pragma mark - 
#pragma mark - Log in user

-(void) loginWithUser:(NSMutableDictionary*) params
{
    [[User currentUser] initialize];
    [self showProgress:@"Loggin in..."];
    [self.backend loginWithUsername:params CompletionHandler:^(NSDictionary *result) {
        if( result ){
            [User initialize:result[@"response"]];
            [self loginToQuickBlox];
        } else {
            [self showMessage:@"Login Fails, Incorrect username/password."];
            [self hideProgress];
        }
    }];
}


-(void) loginToQuickBlox
{
    QBSessionParameters *parameters = [QBSessionParameters new];
    parameters.userLogin = [User currentUser].email;
    parameters.userPassword = qbDefaultPassword;
    
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        // Sign In to QuickBlox Chat
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = session.userID; // your current user's ID
        currentUser.password = qbDefaultPassword; // your current user's password
        
        [User currentUser].chatUser = currentUser;
        [[ChatService instance] loginWithUser:currentUser completionBlock:^{
            [self hideProgress];
            
            // hide alert after delay
            double delayInSeconds = 0.4;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self onAuthenticationSuccess:YES];
            });
            
        }];
        
    } errorBlock:^(QBResponse *response) {
        [self hideProgress];
        [self onAuthenticationSuccess:NO];
    }];
    
    /*
    [QBRequest logInWithUserLogin:[User currentUser].email password:@"dubb@345" successBlock:^(QBResponse *response, QBUUser *user) {
        [User currentUser].chatUser = user;
        
        [self onAuthenticationSuccess];
    } errorBlock:^(QBResponse *response) {
        [self showMessage:@"Error to access chat"];
        [self onAuthenticationSuccess];
    }];*/
}


#pragma mark -
#pragma mark Authentification Success

-(void) onAuthenticationSuccess : (BOOL)chatLogged
{
    User *user = [User currentUser];
    if( user.profileImage == nil ) user.profileImage = [UIImage imageNamed:@"portrait.png"];
    
    if( chatLogged == NO ) {
        user.chatUser = nil;
        [self showMessage:@"Chat is not available"];
    } else {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) registerForRemoteNotifications];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"id": user.userID, @"quickblox_id" : user.quickbloxID, @"email":user.email,
                                                                                   @"username":user.username, @"first":user.firstName, @"last":user.lastName}];
                                                                                
        [defaults setObject:dic forKey:@"DubbUser"];
        [defaults synchronize];
    }
    
    UIViewController *rootController = [self.storyboard instantiateViewControllerWithIdentifier:@"rootController"];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController = rootController;
}


@end
