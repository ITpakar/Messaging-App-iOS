//
//  DubbSignupUsernameViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 29/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbSignupUsernameViewController.h"

@interface DubbSignupUsernameViewController (){
    __weak IBOutlet UITextField *txtUsername;
    __weak IBOutlet UITextField *txtPassword;
}


@end

@implementation DubbSignupUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}


-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void) setupUI
{
    CAShapeLayer *topmaskLayer = [CAShapeLayer layer];
    topmaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:txtUsername.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    txtUsername.layer.mask = topmaskLayer;
    txtUsername.layer.borderWidth = 1;
    txtUsername.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    CAShapeLayer *bottommaskLayer = [CAShapeLayer layer];
    bottommaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:txtPassword.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    txtPassword.layer.mask = bottommaskLayer;
    txtPassword.layer.borderWidth = 1;
    txtPassword.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Sign up

- (IBAction)onSignup:(id)sender {
    if( [txtUsername.text isEqualToString:@""] ){
        [self showMessage:@"Please input username"];
        return;
    }
    
    if( [txtPassword.text isEqualToString:@""] ){
        [self showMessage:@"Please input password"];
        return;
    }
    
    [self registerUserWithUsername:@{@"username":txtUsername.text, @"password":txtPassword.text}];
}


#pragma mark -
#pragma mark Navigation

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
