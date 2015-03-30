//
//  DubbSignUpViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbSignUpViewController.h"


@interface DubbSignUpViewController (){
    
}

@end

@implementation DubbSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Twitter Register

- (IBAction)onRegisterWithGoogle:(id)sender {
    
    [self googlePlusLogin];
    
}


#pragma mark - 
#pragma mark Facebook Registration

- (IBAction)onRegisterWithFacebook:(id)sender {
    
    [self facebookLogin];
    
}


#pragma mark -
#pragma mark Navigation

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
