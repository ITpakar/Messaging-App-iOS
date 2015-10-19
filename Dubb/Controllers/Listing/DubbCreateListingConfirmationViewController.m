//
//  DubbCreateListingConfirmationViewController.m
//  Dubb
//
//  Created by andikabijaya on 4/25/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <Social/Social.h>

#import <AddressBookUI/AddressBookUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SZTextView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"
#import "DubbCreateListingConfirmationShareViewController.h"
#import "DubbCreateListingConfirmationViewController.h"


#define commonShareText(listingTitle)  [NSString stringWithFormat:@"Checkout this listing %@. Download app at http://www.dubb.com/app", listingTitle]
#define disablingReasonText  @"For your Post to go live, we require that you share this through at least one of the of the channels listed on this page"

@interface DubbCreateListingConfirmationViewController()<FHSTwitterEngineAccessTokenDelegate> {
    SLComposeViewControllerCompletionHandler __block completionHandler;
}
@property (strong, nonatomic) IBOutlet UILabel *listingTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *listingImageView;
@property (strong, nonatomic) IBOutlet SZTextView *shareTextView;
@property (strong, nonatomic) IBOutlet UIView *previewContainerView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *orderAmountLabel;
@property (strong, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *twitterSwitch;


@end

@implementation DubbCreateListingConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:twitterConsumerKey andSecret:twitterConsumerSecret];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    self.listingTitleLabel.text = self.listingTitle;
    
    self.listingImageView.image = self.mainImage;
    self.orderAmountLabel.text = [NSString stringWithFormat:@"$%ld", (long)self.baseServicePrice];
    self.previewContainerView.layer.borderWidth = 1.0f;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.listingLocation.locationCoordinates.latitude longitude:self.listingLocation.locationCoordinates.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler: ^ (NSArray  *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks firstObject];
        if(placemark) {
            
            NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
            NSString *state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
            
            NSString *locationString = [NSString stringWithFormat:@"%@, %@", city, state];
            self.listingLocation.name = city;
            self.listingLocation.address = locationString;
            self.locationLabel.text = self.listingLocation.address;
        }
    }];

    
    self.previewContainerView.layer.borderColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f].CGColor;
}
- (IBAction)twitterSwitchValueChanged:(id)sender {
    if (self.twitterSwitch.isOn) {
        UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
            
            [self.twitterSwitch setOn:success];
            
        }];
        
        [self presentViewController:loginController animated:YES completion:nil];
    }
    
}

- (IBAction)facebookSwitchValueChanged:(id)sender {
    
    if (self.facebookSwitch.isOn) {
        [self performPublishAction:^{
            
            
        }];
    }

    
}
- (IBAction)skipButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Are you sure you don't want to share your listing on Facebook or Twitter?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Yes, I'm sure", @"Ok action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self performSegueWithIdentifier:@"displayCreateListingConfirmationShareSegue" sender:nil];
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Take me back", @"Cancel action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)postButtonTapped:(id)sender {
    
    if (self.twitterSwitch.isOn) {
        [[FHSTwitterEngine sharedEngine] postTweet:[NSString stringWithFormat:@"%@ %@", self.shareTextView.text, self.slugUrlString]];
    }
    if (self.facebookSwitch.isOn) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"", @"name",
                                       @"", @"caption",
                                       self.shareTextView.text, @"message",
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
                                
                                  [self performSegueWithIdentifier:@"displayCreateListingConfirmationShareSegue" sender:nil];
                              }];

    } else {
        [self performSegueWithIdentifier:@"displayCreateListingConfirmationShareSegue" sender:nil];
    }
    
}
- (void)twitterEngineControllerDidCancel {
    self.twitterSwitch.on = NO;
}
// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    
    if ([FBSession.activeSession isOpen]) {
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
    }
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
                                                 } else {
                                                     [self.facebookSwitch setOn:NO];
                                                 //For this example, ignore errors (such as if user cancels).
                                                 }
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

#pragma mark - FHSTwitterEngineAccessTokenDelegate
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"displayCreateListingConfirmationShareSegue"]) {
        DubbCreateListingConfirmationShareViewController *vc = segue.destinationViewController;
        vc.listingTitle = self.listingTitle;
        vc.listingLocation = self.listingLocation;
        vc.mainImage = self.mainImage;
        vc.baseServicePrice = self.baseServicePrice;
        vc.slugUrlString = self.slugUrlString;
    }

}


@end
