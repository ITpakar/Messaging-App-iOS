//
//  DubbPasswordResetViewController.m
//  Dubb
//
//  Created by first last on 25/07/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbPasswordResetViewController.h"

@interface DubbPasswordResetViewController (){
    __weak IBOutlet UITextField *txtEmail;
}
@end

@implementation DubbPasswordResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void) setupUI
{
    CALayer *bottomBorder = [CALayer layer];
    CALayer *topBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, txtEmail.frame.size.height - 1, txtEmail.frame.size.width+50, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:0 green:0.1 blue:0.1 alpha:0.1].CGColor;
    topBorder.frame = CGRectMake(0.0f, 0, txtEmail.frame.size.width+50, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed:0 green:0.1 blue:0.1 alpha:0.1].CGColor;

    [txtEmail.layer addSublayer:bottomBorder];
    [txtEmail.layer addSublayer:topBorder];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    txtEmail.leftView = paddingView;
    txtEmail.leftViewMode = UITextFieldViewModeAlways;
}

- (IBAction)onReset:(id)sender {
    
    if([txtEmail.text isEqualToString:@""]){
        [self showMessage:@"Please enter email."];
        return;
    }
    
    [self showProgress:@"Sending..."];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:txtEmail.text forKey:@"email"];

    [self.backend resetPassword:params CompletionHandler:^(NSDictionary *result) {
        if( result ){
            [self showMessage:@"Instructions on retrieving your password have been emailed to you. If you need further assistance please reach us through our support menu."];
            [self hideProgress];
        } else {
            [self showMessage:[NSString stringWithFormat:@"User with email: %@ not found.", txtEmail.text]];
            [self hideProgress];
        }
    }];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
