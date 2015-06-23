//
//  BaseViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHPBackend.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>

@interface BaseViewController : UIViewController 

@property BackendBase           *backend;
@property(nonatomic, strong) NSString *reasonForDisablingMenu;
- (void)showMessage : (NSString *)message;
- (void)showCreateListingTableViewController ;
- (void)showAlertForLogIn;

//MB Progres
- (void)showProgress:(NSString *)message;
- (void)hideProgress;

@end
