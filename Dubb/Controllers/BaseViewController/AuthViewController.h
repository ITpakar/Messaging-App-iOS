//
//  AuthViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 23/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//


@interface AuthViewController : BaseViewController

//Google+, Facebook
-(void) googlePlusLogin;
-(void) facebookLogin;
-(void) loginWithUser:(NSMutableDictionary*) params;
-(void) registerUserWithUsername : (NSDictionary*)params;
-(void) loginToQuickBlox;
-(void) onAuthenticationSuccess : (BOOL)chatLogged;
-(int) registerUserToDubb : (NSDictionary*) params;
-(int) updateUserToDubbWithUserID: (NSString *)userID params: (NSDictionary*) params;
-(void) signUpWithSocial : (NSInteger) userType
                 socialID:(NSString*)userid
                    email:(NSString*)email
                firstName:(NSString*)fname
                 lastName:(NSString*)lname
          profileImageURL:(NSString*)url
                   gender:(NSString*)gender;
@end
