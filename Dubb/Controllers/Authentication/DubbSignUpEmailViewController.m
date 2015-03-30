//
//  DubbSignUpEmailViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbSignUpEmailViewController.h"


@interface DubbSignUpEmailViewController (){
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtUsername;
    __weak IBOutlet UITextField *txtPassword;
}

@end

@implementation DubbSignUpEmailViewController

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
    topmaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:txtEmail.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    txtEmail.layer.mask = topmaskLayer;
    txtEmail.layer.borderWidth = 1;
    txtEmail.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    CAShapeLayer *bottommaskLayer = [CAShapeLayer layer];
    bottommaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:txtPassword.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    txtPassword.layer.mask = bottommaskLayer;
    txtPassword.layer.borderWidth = 1;
    txtPassword.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    txtUsername.layer.borderWidth = 1;
    txtUsername.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
