//
//  AuthViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 23/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//


@interface AuthViewController : BaseViewController

//FB, Twitter
-(void) googlePlusLogin;
-(void) facebookLogin;
-(void) loginWithUser:(NSMutableDictionary*) params;
-(void) registerUserWithUsername : (NSDictionary*)params;

@end
