//
//  DubbSignInViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbSignInViewController.h"

@interface DubbSignInViewController (){
    __weak IBOutlet UITextField *txtUsername;
    __weak IBOutlet UITextField *txtPassword;
}

@end

@implementation DubbSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - 
#pragma mark Sign In

//Login with Twitter
- (IBAction)onLoginWithGoogle:(id)sender {
    [self googlePlusLogin];
}


//Login with Facebook
- (IBAction)onLoginWithFacebook:(id)sender {
    [self facebookLogin];
}

//Login with Username and Password
- (IBAction)onLogin:(id)sender {
    if( [txtUsername.text isEqualToString:@""] ){
        [self showMessage:@"Please input username"];
        return;
    }
    
    if( [txtPassword.text isEqualToString:@""] ){
        [self showMessage:@"Please input password"];
        return;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:txtPassword.text forKey:@"password"];
    
    if( [emailTest evaluateWithObject:txtUsername.text] )
        [params setValue:txtUsername.text forKey:@"email"];
    else
        [params setValue:txtUsername.text forKey:@"username"];
        
    [self loginWithUser:params];
    
}


#pragma mark -
#pragma mark Navigation

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
