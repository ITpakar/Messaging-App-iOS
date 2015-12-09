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

- (id)initialize {
    self.cloudinary = [[CLCloudinary alloc] init];
    [self.cloudinary.config setValue:@"dubb-com" forKey:@"cloud_name"];
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    // Do any additional setup after loading the view.
    
    backend = [PHPBackend sharedConnection];
    
    UIButton *menuButton = (UIButton*)[self.view viewWithTag:kMenuButton];
    [menuButton addTarget:self action:@selector(onMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // This function needed to make clicking buttons easier on small screens
    // After clicking on toolbar we creating touch square around touch point
    // For eg, if we touched outside small button but touch square intersects
    // button frame rectangle - button will be pressed anyway

    CGFloat w = 100; // Touch square size
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];

    // Assume that view with upper left corner at (0,0) is toolbar
    if(CGPointEqualToPoint(view.frame.origin, CGPointMake(0, 0)) && view.frame.size.height < 100) {
        NSArray *subviews = [view subviews];

        // Go through all the buttons in toolbar
        for(UIView *v in subviews) {
            if([v isKindOfClass:[UIButton class]]) {
                CGPoint loc = [touch locationInView:view];
                CGRect touchRect = CGRectMake(loc.x - w/2, loc.y - w/2, w, w);
                if (CGRectIntersectsRect(touchRect, v.frame)) {
                    [(UIButton*)v sendActionsForControlEvents:UIControlEventTouchUpInside];
                    return;
                }
            }
        }
    }
}

- (void)onMenu
{
    if (self.reasonForDisablingMenu) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                                 message:self.reasonForDisablingMenu
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        
        [self.sideMenuViewController presentLeftMenuViewController];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMessage:(NSString *)message
{
    UIAlertView *msgView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [msgView show];
}

- (void)showCreateListingTableViewController {
    
    if ([[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""]) {
        [self showAlertForLogIn];
    } else {
        [self performSegueWithIdentifier:@"showCreateListingTableViewControllerSegue" sender:nil];
    }
    
}

- (void)showAlertForLogIn {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:@"Please Sign In/Sign Up first to access this feature."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *logInAction = [UIAlertAction
                                  actionWithTitle:@"Log In"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [self showLoginView];
                                  }];
    [alertController addAction:logInAction];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)showLoginView {
    
    UIViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainController"];
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController = mainController;
    
}

- (NSURL*)prepareVideoUrl:(NSString*)url {
    NSString* result = [[self prepareImageUrl:url withWith:0 withHeight:0 withGravity:nil] absoluteString];
    result = [result stringByAppendingString:@".mp4"];
    return [NSURL URLWithString:[result stringByReplacingOccurrencesOfString:@"/image/" withString:@"/video/"]];
}

- (NSURL*)prepareImageUrl:(NSString*)url {
    return [self prepareImageUrl:url withWith:0 withHeight:0 withGravity:nil];
}

- (NSURL*)prepareImageUrl:(NSString*)url size:(CGSize) size gravity:(NSString*)gravity {
    return [self prepareImageUrl:url withWith:size.width withHeight:size.height withGravity:gravity];
}

- (NSURL*)prepareImageUrl:(NSString*)url size:(CGSize) size {
    return [self prepareImageUrl:url withWith:size.width withHeight:size.height withGravity:nil];
}

- (NSURL*)prepareImageUrl:(NSString*)url
                 withWith:(int)width
               withHeight:(int)height
              withGravity:(NSString*)gravity {
    
    NSURL* imageUrl = [NSURL URLWithString:url];
    NSString* imageUrlString;

    if ([[imageUrl scheme] isEqualToString:@"cloudinary"]) {
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];

        if(width > 0 || height > 0) {
            CLTransformation *transformation = [CLTransformation transformation];

            [transformation setWidthWithInt: width];
            [transformation setHeightWithInt: height];
//            [transformation setAngleWithInt:30];
            [transformation setCrop: @"fill"];
            
            if(gravity){
                [transformation setGravity:gravity];
            }
            
            [options setValue:transformation forKey:@"transformation"];
        }
        
        imageUrlString = [self.cloudinary url:[NSString stringWithFormat:@"%@%@", [imageUrl host], [imageUrl path]] options:options];
    } else {
        imageUrlString = url;
    }
    return [NSURL URLWithString:imageUrlString];
}

- (void) uploadImage:(UIImage *)image CompletionHandler:(void (^)(NSString *urlString)) handler {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *fileName = [NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]];
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [fileManager createFileAtPath:tempFilePath contents:data attributes:nil];
    [self uploadFileWithFileName:fileName SourcePath:tempFilePath FileURL:nil Type:nil CompletionHandler:^(NSString *urlString) {
        handler(urlString);
    }];
}


- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath FileURL:(NSURL *)fileURL Type:(NSString*) type CompletionHandler:(void (^)(NSString *urlString)) handler  {
    NSURL *fullPath;
    if (sourcePath) {
        fullPath = [NSURL fileURLWithPath:sourcePath
                              isDirectory:NO];
    } else {
        fullPath = fileURL;
    }
    
    if (type) {
        [self showProgress:@"Uploading Video..."];
    } else {
        [self showProgress:@"Uploading Image..."];
    }
    [self.backend getUploadSignatureWithCompletionHandler: ^(NSDictionary *result) {
        if(result) {
            CLUploader* mobileUploader = [[CLUploader alloc] init:self.cloudinary delegate:self];
            NSMutableDictionary* options = result[@"response"];
            //[options setValue:@YES forKey:@"sync"];
            
            if (type) {
                [options setValue:type forKey:@"resource_type"];
            }
            
            [mobileUploader upload:fullPath.path options:options withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
                NSString *cloudinaryURL = [NSString stringWithFormat:@"cloudinary://%@", successResult[@"public_id"]];
                handler(cloudinaryURL);
                [self hideProgress];
            } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
                
                
            }];
        }
    }];
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
