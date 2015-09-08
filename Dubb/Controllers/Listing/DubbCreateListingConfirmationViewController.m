//
//  DubbCreateListingConfirmationViewController.m
//  Dubb
//
//  Created by andikabijaya on 4/25/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <Social/Social.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import "SZTextView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DubbCreateListingConfirmationViewController.h"

#define commonShareText(listingTitle)  [NSString stringWithFormat:@"Checkout this listing %@. Download app at http://www.dubb.com/app", listingTitle]
#define disablingReasonText  @"For your Post to go live, we require that you share this through at least one of the of the channels listed on this page"

@interface DubbCreateListingConfirmationViewController () {
    SLComposeViewControllerCompletionHandler __block completionHandler;
}
@property (strong, nonatomic) IBOutlet UILabel *listingTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *listingImageView;
@property (strong, nonatomic) IBOutlet SZTextView *shareTextView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *orderAmountLabel;
@property (strong, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *twitterSwitch;

@end

@implementation DubbCreateListingConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listingTitleLabel.text = self.listingTitle;
    self.locationLabel.text = self.listingLocation.address;
    self.listingImageView.image = self.mainImage;
    self.orderAmountLabel.text = [NSString stringWithFormat:@"$%ld", (long)self.baseServicePrice];
}
- (IBAction)twitterSwitchValueChanged:(id)sender {
    
}

- (IBAction)facebookSwitchValueChanged:(id)sender {
    
    if (self.facebookSwitch.isOn) {
        [self performPublishAction:^{
            
            
        }];
    }

    
}
- (IBAction)skipButtonTapped:(id)sender {
    
}
- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)postButtonTapped:(id)sender {
    
    if (self.facebookSwitch.isOn) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"", @"name",
                                       @"", @"caption",
                                       self.shareTextView.text, @"description",
                                       nil];
        
        // Make the request
        [FBRequestConnection startWithGraphPath:@"/me/feed"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error) {
                                      // Loading message
                                      NSLog(@"result: %@", result);
                                  } else {
                                      // An error occurred, we need to handle the error
                                      // See: https://developers.facebook.com/docs/ios/errors
                                      NSLog(@"%@", error.description);
                                  }
                              }];

    }
    
}

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        NSLog(@"%@", FBSession.activeSession.permissions);
        // If we don't have an open active session, then we request to open an active session
        if (![FBSession.activeSession isOpen]) {
            NSLog(@"Open active session with publish permission.");
            [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                                defaultAudience:FBSessionDefaultAudienceFriends
                                                  allowLoginUI:YES
                                             completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                                 if (!error) {
                                                     action();
                                                 }
                                                 //For this example, ignore errors (such as if user cancels).
                                             }];
        }
        else {
            // if we don't already have the permission, then we request it now
            [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                completionHandler:^(FBSession *session, NSError *error) {
                                                    if (!error) {
                                                        action();
                                                    }
                                                    //For this example, ignore errors (such as if user cancels).
                                                }];
        }
    }
    // If we don't have an open active session, then we request to open an active session
    else if (![FBSession.activeSession isOpen]) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (!error) {
                                                 action();
                                             }
                                             //For this example, ignore errors (such as if user cancels).
                                         }];
    }
    else {
        NSLog(@"FB session %d", [FBSession.activeSession isOpen]);
        action();
    }
    
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
