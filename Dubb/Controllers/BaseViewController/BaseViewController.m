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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning"
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
