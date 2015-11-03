//
//  DubbProfileViewController.h
//  Dubb
//
//  Created by andikabijaya on 6/12/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "BaseViewController.h"
#import "PaypalMobile.h"
#import "SZTextView.h"
@interface DubbProfileViewController : BaseViewController <PayPalFuturePaymentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImage *chosenImage;
    NSDictionary *userInfo;
    
}
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *mobileTextField;
@property (strong, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet SZTextView *bioTextView;
@property (strong, nonatomic) IBOutlet UILabel *availableCharacterNumberLabel;

@end
