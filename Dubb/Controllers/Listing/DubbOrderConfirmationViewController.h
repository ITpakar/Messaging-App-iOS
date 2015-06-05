//
//  DubbOrderConfirmationViewController.h
//  Dubb
//
//  Created by andikabijaya on 5/27/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ChatViewController.h"
@interface DubbOrderConfirmationViewController : BaseViewController <QBActionStatusDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *orderDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderIDLabel;
@property (strong, nonatomic) IBOutlet UIImageView *listingImageView;
@property (strong, nonatomic) IBOutlet UILabel *listingTItleLabel;
@property (strong, nonatomic) IBOutlet UILabel *listingSellerNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *shareButtonsContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *upArrowButton;
@property (strong, nonatomic) ChatViewController *chatViewController;
@property (strong, nonatomic) NSString *userType;
@property (strong, nonatomic) NSDictionary *listingInfo;
@property (strong, nonatomic) NSMutableArray *purchasedAddOnsDetails;
@property (strong, nonatomic) NSString *orderID;
@property (strong, nonatomic) NSString *opponentQuickbloxID;
@property (strong, nonatomic) NSString *userImageURL;
@property (strong, nonatomic) NSDictionary *buyerInfo;
@property (nonatomic)         NSInteger totalAmountPurchased;
@end
