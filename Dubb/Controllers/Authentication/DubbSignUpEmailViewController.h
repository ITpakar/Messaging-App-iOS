//
//  DubbSignUpEmailViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthViewController.h"
@interface DubbSignUpEmailViewController : AuthViewController
@property(nonatomic) NSDictionary *userInfo;
@property(nonatomic) NSString *userId;
@end
