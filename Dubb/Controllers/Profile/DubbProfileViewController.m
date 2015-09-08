//
//  DubbProfileViewController.m
//  Dubb
//
//  Created by andikabijaya on 6/12/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "AppDelegate.h"
#import "DubbProfileViewController.h"
#import "UIImage+fixOrientation.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <AWSiOSSDKv2/S3.h>

#define MAX_CHARACTER_NUMBER 144
@implementation DubbProfileViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.backend getUser:[User currentUser].userID CompletionHandler:^(NSDictionary *result) {
        
        if (result) {
            
            userInfo = result[@"response"];
            [User initialize:userInfo];
            [self initViews];
            
        }
        
    }];
    
}

- (void)initViews {
    
    self.firstNameTextField.text = [self stringValueForKey:@"first" from:userInfo];
    self.lastNameTextField.text = [self stringValueForKey:@"last" from:userInfo];
    self.emailTextField.text = [self stringValueForKey:@"email" from:userInfo];
    self.mobileTextField.text = [self stringValueForKey:@"phone" from:userInfo];
    self.userNameTextField.text = [self stringValueForKey:@"username" from:userInfo];
    self.zipCodeTextField.text = [self stringValueForKey:@"zip" from:userInfo];
    self.bioTextView.text = [self stringValueForKey:@"bio" from:userInfo];
    if (![userInfo[@"image"] isKindOfClass:[NSNull class]]) {
        [self.profileImageView sd_setImageWithURL:[self prepareImageUrl:userInfo[@"image"][@"url"]]];
    }
    
    [self.bioTextView setPlaceholder:@"Bio - MAX 144 Characters"];
    
}

- (IBAction)paymentSettingsButtonTapped:(id)sender {
    
    PayPalFuturePaymentViewController *futurePaymentViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:((AppDelegate*)[UIApplication sharedApplication].delegate).payPalConfig delegate:self];
    [self presentViewController:futurePaymentViewController animated:YES completion:nil];
    
}

- (IBAction)saveButtonTapped:(id)sender {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (!chosenImage && [userInfo[@"image"] isKindOfClass:[NSNull class]]) {
        [self showMessage:@"Please upload the profile image."];
        return;
    }
    
    if (![self.firstNameTextField.text isEqualToString:[self stringValueForKey:@"first" from:userInfo]]) {
        params[@"first"] = self.firstNameTextField.text;
    }
    
    if (![self.lastNameTextField.text isEqualToString:[self stringValueForKey:@"last" from:userInfo]]) {
        params[@"last"] = self.lastNameTextField.text;
    }
    
    if (![self.emailTextField.text isEqualToString:[self stringValueForKey:@"email" from:userInfo]]) {
        params[@"email"] = self.emailTextField.text;
    }
    
    if (![self.userNameTextField.text isEqualToString:[self stringValueForKey:@"username" from:userInfo]]) {
        params[@"username"] = self.userNameTextField.text;
    }
    
    if (![self.mobileTextField.text isEqualToString:[self stringValueForKey:@"phone" from:userInfo]]) {
        params[@"phone"] = self.mobileTextField.text;
    }
    
    if (![self.bioTextView.text isEqualToString:[self stringValueForKey:@"bio" from:userInfo]]) {
        params[@"bio"] = self.bioTextView.text;
    }

    if (![self.passwordTextField.text isEqualToString:@""]) {
        params[@"password"] = self.passwordTextField.text;
    }
    
    if (![self.zipCodeTextField.text isEqualToString:[self stringValueForKey:@"zip" from:userInfo]]) {
        params[@"zip"] = self.zipCodeTextField.text;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", [self.zipCodeTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        
        [request setHTTPMethod:@"POST"];
        
        NSError *err;
        NSURLResponse *response;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *resSrt = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
        
        NSLog(@"got response==%@", resSrt);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSString *lataddr=[[[[[dict objectForKey:@"results"] objectAtIndex:0]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
        
        NSString *longaddr=[[[[[dict objectForKey:@"results"] objectAtIndex:0]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
        
        for (NSDictionary *addressComponents in dict[@"results"][0][@"address_components"]) {
            NSString *type = addressComponents[@"types"][0];
            if ([type isEqualToString:@"administrative_area_level_2"]) {
                params[@"city"] = addressComponents[@"long_name"];
            }
            if ([type isEqualToString:@"administrative_area_level_1"]) {
                params[@"state"] = addressComponents[@"long_name"];
            }
            if ([type isEqualToString:@"country"]) {
                params[@"country"] = addressComponents[@"long_name"];
            }
        }
        params[@"lat"] = lataddr;
        params[@"longitude"] = longaddr;
        
        NSLog(@"The resof latitude=%@", lataddr);
        
        NSLog(@"The resof longitude=%@", longaddr);
    }
    
    if (chosenImage) {
        NSString *imageURL = [self uploadImage];
        params[@"image"] = imageURL;
        [self uploadImageToQuickblox];
    }
    [self showProgress:@"Saving profile changes"];
    [self.backend updateUser:[User currentUser].userID Parameters:params CompletionHandler:^(NSDictionary *result) {
        if (result) {
            [User currentUser].profileImage = chosenImage;
        }
        [self hideProgress];
    }];
}

- (IBAction)signOutButtonTapped:(id)sender {
    
    [[GPPSignIn sharedInstance] signOut];
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    if([[QBChat instance] isLoggedIn]){
        [[ChatService instance] logout];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"DubbUser"];
    [defaults synchronize];
    
    [[User currentUser] initialize];
    
    UIViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainController"];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController = mainController;

}
- (IBAction)profileImageViewTapped:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Where do you want to get photo?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Gallery", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
    
}
#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
            
            break;
        default:
            break;
    }
    
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = [info[UIImagePickerControllerEditedImage] fixOrientation];
    self.profileImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
#pragma mark - PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    NSLog(@"PayPal Future Payment Authorization Success!");
    
    [self sendFuturePaymentAuthorizationToServer:futurePaymentAuthorization];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    NSLog(@"PayPal Future Payment Authorization Canceled");

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendFuturePaymentAuthorizationToServer:(NSDictionary *)authorization {
    // TODO: Send authorization to server
    NSLog(@"Here is your authorization:\n\n%@\n\nSend this to your server to complete future payment setup.", authorization);
}

- (NSString *)stringValueForKey: (NSString *)key from:(NSDictionary *)dict {
    
    if (![dict objectForKey:key] || [[dict objectForKey:key] isKindOfClass:[NSNull class]]) {
        
        return @"";
        
    } else {
        
        return [dict objectForKey:key];
        
    }
    
    
}

- (NSString *) uploadImage{
    
    NSString *imageURL;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    UIImage *image = chosenImage;
        
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *fileName = [NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]];
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [fileManager createFileAtPath:tempFilePath contents:data attributes:nil];
    imageURL = [NSString stringWithFormat:@"cloudinary://%@", fileName];
    [self uploadFileWithFileName:fileName SourcePath:tempFilePath];

    
    return imageURL;
}

- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath {
    [self uploadFileWithFileName:fileName SourcePath:sourcePath Type:nil];
}

- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath Type:(NSString*) type {
    NSURL *fullPath;
    fullPath = [NSURL fileURLWithPath:sourcePath isDirectory:NO];

    [self.backend getUploadSignature:fileName CompletionHandler: ^(NSDictionary *result) {
        if(result) {
            CLUploader* mobileUploader = [[CLUploader alloc] init:self.cloudinary delegate:nil];
            NSMutableDictionary* options = result[@"response"];
            [options setValue:@YES forKey:@"sync"];

            if (type) {
                [options setValue:type forKey:@"resource_type"];
            }

            [mobileUploader upload:fullPath.path options:options];
        }
    }];
}

- (void)uploadFileWithFileName1:(NSString *)fileName SourcePath:(NSString *)sourcePath {
    
    NSURL *fullPath = [NSURL fileURLWithPath:sourcePath
                                 isDirectory:NO];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"listing-image-uploads";
    uploadRequest.key = [NSString stringWithFormat:@"completed/%@", fileName];
    uploadRequest.body = fullPath;
    uploadRequest.contentType = @"image/jpeg";
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        NSLog(@"Fail %@", task.error);
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
            
            //Uploading image fails
            
        }
        
        if (task.result) {
            
            // The file uploaded successfully.
            
            NSLog(@"Success: %@", task.result);
        }
        return nil;
    }];
    
}

- (void)uploadImageToQuickblox {
    
    NSData *data = UIImagePNGRepresentation(chosenImage);
    
    [QBRequest TUploadFile:data fileName:@"MyAvatar" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *blob) {
        
        QBUUser *user = [QBUUser user];
        user.ID = [[User currentUser].quickbloxID integerValue];
        user.blobID = blob.ID;
        [QBRequest updateUser:user successBlock:nil errorBlock:nil];
        
    } statusBlock:nil errorBlock:nil];

}
#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self.availableCharacterNumberLabel setText:[NSString stringWithFormat:@"%ld", MAX_CHARACTER_NUMBER - [textView.text length]]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > MAX_CHARACTER_NUMBER) ? NO : YES;
}

@end
