//
//  DubbSignUpEmailViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbSignUpEmailViewController.h"
#import "TextFieldValidator.h"
#import "M13Checkbox.h"
#import "DubbWebViewController.h"
#import "AppDelegate.h"

#define REGEX_USER_NAME_LIMIT @"^.{3,10}$"
#define REGEX_USER_NAME @"[A-Za-z0-9_]{3,10}"
#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_PASSWORD_LIMIT @"^.{6,20}$"

@interface DubbSignUpEmailViewController (){
    __weak IBOutlet TextFieldValidator *txtEmail;
    __weak IBOutlet TextFieldValidator *txtUsername;
    __weak IBOutlet TextFieldValidator *txtPassword;
    __weak IBOutlet TextFieldValidator *txtFirstname;
    __weak IBOutlet TextFieldValidator *txtLastName;
    __weak IBOutlet M13Checkbox *chkboxTogglePasswordSecureEntry;
    
    IBOutlet M13Checkbox *chkboxToggleTermsOfService;
    BOOL isUserNameValid;
    BOOL isEmailValid;
}
@property (strong, nonatomic) IBOutlet UILabel *alreadyMemberLabel;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation DubbSignUpEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    if (self.userInfo) {
        [self initView];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


// UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString {
    if (textField == txtUsername) {
        [self validateUserName:[[textField text] stringByReplacingCharactersInRange:range withString:replacementString]];
    }else if (textField == txtUsername) {
        [self validateEmail:[[textField text] stringByReplacingCharactersInRange:range withString:replacementString]];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == txtUsername) {
        [self validateUserName:textField.text];
    } else {
        [self validateEmail:textField.text];
    }
}

// Helpers

- (void)validateUserName:(NSString *)userName {
    if ([userName isEqualToString:@""]) {
        return;
    }
    [self.backend checkValidityOfUsernameOrEmail:userName CompletionHandler:^(NSDictionary *result) {
        
        if (![result[@"response"] isKindOfClass:[NSNull class]]) {
            [txtUsername showErrorIconForMsg:@"This username is already taken"];
            isUserNameValid = NO;
        } else {
            isUserNameValid = YES;
        }
        
    }];
}

- (void)validateEmail:(NSString *)email {
    if ([email isEqualToString:@""]) {
        return;
    }
    [self.backend checkValidityOfUsernameOrEmail:email CompletionHandler:^(NSDictionary *result) {
        
        if (![result[@"response"] isKindOfClass:[NSNull class]]) {
            [txtEmail showErrorIconForMsg:@"This email is already taken"];
            isEmailValid = NO;
        } else {
            isEmailValid = YES;
        }
        
    }];
}


-(void) initView {
    
    txtEmail.text = self.userInfo[@"email"];
    txtEmail.enabled = NO;
    txtUsername.text = self.userInfo[@"user_name"];
    txtFirstname.text = self.userInfo[@"first"];
    txtLastName.text = self.userInfo[@"last"];

}



-(void) setupUI
{
    CAShapeLayer *roundedMaskLayer = [CAShapeLayer layer];
    roundedMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect:txtEmail.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    chkboxTogglePasswordSecureEntry.titleLabel.text = @"Show Password";
    chkboxTogglePasswordSecureEntry.titleLabel.textColor = [UIColor whiteColor];
    chkboxTogglePasswordSecureEntry.checkAlignment = M13CheckboxAlignmentLeft;
    chkboxTogglePasswordSecureEntry.tintColor = [UIColor clearColor];
    chkboxTogglePasswordSecureEntry.strokeColor = [UIColor whiteColor];
    chkboxTogglePasswordSecureEntry.checkColor = [UIColor colorWithRed:0 green:167.0f/255.0f blue:10.0f/255.0f alpha:1.0f];
    [chkboxTogglePasswordSecureEntry setCheckState:M13CheckboxStateChecked];
    [chkboxTogglePasswordSecureEntry addTarget:self action:@selector(checkChangedValue:) forControlEvents:UIControlEventValueChanged];
    [chkboxTogglePasswordSecureEntry setCheckState:M13CheckboxStateUnchecked];
    
    chkboxToggleTermsOfService.tintColor = [UIColor clearColor];
    chkboxToggleTermsOfService.strokeColor = [UIColor whiteColor];
    chkboxToggleTermsOfService.checkColor = [UIColor colorWithRed:0 green:167.0f/255.0f blue:10.0f/255.0f alpha:1.0f];
    [chkboxToggleTermsOfService addTarget:self action:@selector(checkChangedValue:) forControlEvents:UIControlEventValueChanged];
    [chkboxToggleTermsOfService setCheckState:M13CheckboxStateUnchecked];
    // Validation Criteria
    
    isUserNameValid = YES;
    isEmailValid = YES;
    
    [txtUsername addRegx:REGEX_USER_NAME_LIMIT withMsg:@"User name needs to be between 3 and 10 characters"];
    [txtUsername addRegx:REGEX_USER_NAME withMsg:@"Only alpha numeric characters and _ are allowed"];
    [txtEmail addRegx:REGEX_EMAIL withMsg:@"Enter valid email"];
    [txtPassword addRegx:REGEX_PASSWORD_LIMIT withMsg:@"Password needs to be between 6 and 20 characters"];
}

- (void)checkChangedValue:(id)sender
{
    if (sender == chkboxTogglePasswordSecureEntry) {
        [self toggleTextFieldSecureEntry:txtPassword];
    }
    
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

- (IBAction)onClose:(id)sender {
    [self onAuthenticationSuccess:NO];
}
- (IBAction)signUpButtonTapped:(id)sender {
    
    
    
    BOOL isAgreedToTermsOfService = chkboxToggleTermsOfService.checkState == M13CheckboxStateChecked;
    if (!isAgreedToTermsOfService) {
        [self showMessage:@"Please read our terms of service and agree to it."];
        return;
    }
    
    if ([txtUsername validate] && [txtEmail validate] && [txtPassword validate] && [txtFirstname validate] && [txtLastName validate] && isUserNameValid && isEmailValid ) {
        
        NSDictionary *params = @{ @"email":txtEmail.text,
                                  @"password":txtPassword.text,
                                  @"username":txtUsername.text,
                                  @"first":txtFirstname.text, @"last":txtLastName.text,
                                  @"lat":([User currentUser].latitude == nil) ? @"37.33" : [User currentUser].latitude,
                                  @"longitude":([User currentUser].longitude == nil) ? @"-122.03" : [User currentUser].longitude,
                                  @"city":([User currentUser].city == nil) ? @"Palo Alto" : [User currentUser].city,
                                  @"state":([User currentUser].state == nil) ? @"CA" : [User currentUser].state,
                                  @"country":([User currentUser].country == nil) ? @"US" : [User currentUser].country};
        if (self.userInfo) {
            
            [self updateUserToDubbWithUserID:self.userId params:params];
            
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SHOWN_INTRODUCTION"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self registerUserToDubb:params];
            
        }
    } else {
        
        [self showMessage:@"Your input is invalid. Please tap on info button to see what is wrong."];
        
    }

    
}
-(void) toggleTextFieldSecureEntry: (UITextField*) textField {
    BOOL isFirstResponder = textField.isFirstResponder; //store whether textfield is firstResponder
    
    if (isFirstResponder) [textField resignFirstResponder]; //resign first responder if needed, so that setting the attribute to YES works
    textField.secureTextEntry = !textField.secureTextEntry; //change the secureText attribute to opposite
    if (isFirstResponder) [textField becomeFirstResponder]; //give the field focus again, if it was first responder initially
    
    
}
- (IBAction)termsOfServiceButtonTapped:(id)sender {
    
    DubbWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbWebViewController"];
    vc.titleString = @"Terms of Service";
    [self presentViewController:vc animated:YES completion:nil];

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
