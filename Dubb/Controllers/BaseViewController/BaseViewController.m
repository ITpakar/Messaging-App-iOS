//
//  BaseViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface BaseViewController () 
@end

@implementation BaseViewController

@synthesize backend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    backend = [PHPBackend sharedConnection];
    
    UIButton *menuButton = (UIButton*)[self.view viewWithTag:kMenuButton];
    [menuButton addTarget:self action:@selector(onMenu) forControlEvents:UIControlEventTouchUpInside];
}

-(void) onMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showMessage:(NSString *)message
{
    UIAlertView *msgView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [msgView show];
}



#pragma mark -
#pragma mark - MBProgressHUD
- (void) showProgress:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    hud.labelFont = [UIFont fontWithName:@"OpenSans" size:hud.labelFont.pointSize];
}

- (void) hideProgress
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


@end
