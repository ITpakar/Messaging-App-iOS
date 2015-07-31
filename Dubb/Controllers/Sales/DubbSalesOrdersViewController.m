//
//  DubbSalesViewController.m
//  Dubb
//
//  Created by andikabijaya on 5/29/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+Helper.h"
#import "DubbOrderConfirmationViewController.h"
#import "DubbSalesOrdersViewController.h"

enum DubbListingCellTag {
    kDubbListingCellProfileImageViewTag = 100,
    kDubbListingCellTitleLabelTag,
    kDubbListingCellUserNameLabelTag,
    kDubbListingCellOrderedDateLabelTag,
    kDubbListingCellAmountLabelTag,
    kDubbListingCellProgressIndicatorImageView,
    kDubbListingCellCategoryLabelTag
};

@interface DubbSalesOrdersViewController() {
    
    NSArray *orderDetails;
    NSString *opponentType;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UILabel *emptyViewLabel;

@property (strong, nonatomic) IBOutlet UIView *createListingButtonView;
@property (strong, nonatomic) IBOutlet UIButton *createListingButton;
@property (strong, nonatomic) IBOutlet UILabel *navigationBarTitleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *createListingViewHeightConstraint;

@end

@implementation DubbSalesOrdersViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self.userType isEqualToString:@"buyer"]) {
        self.createListingButton.hidden = YES;
        self.createListingViewHeightConstraint.constant = 0;
        self.navigationBarTitleLabel.text = @"ORDERS";
        [self.view layoutIfNeeded];
    } else {
        self.navigationBarTitleLabel.text = @"SALES";
        self.emptyViewLabel.text = @"Sorry, you have no orders yet";
    }
    
    [self showProgress:@"Loading..."];
    [self.backend getAllOrdersForUserType:self.userType CompletionHandler:^(NSDictionary *result) {
        
        [self hideProgress];
        orderDetails = result[@"response"];
        if (orderDetails.count > 0) {
            [self.tableView reloadData];
        } else {
            self.emptyView.hidden = NO;
            
        }
        
        
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return orderDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DubbListingCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbListingCellProfileImageViewTag];
    UIImageView *progressIndicatorImageView = (UIImageView *)[cell viewWithTag:kDubbListingCellProgressIndicatorImageView];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kDubbListingCellTitleLabelTag];
    UILabel *userNameLabel = (UILabel *)[cell viewWithTag:kDubbListingCellUserNameLabelTag];
    UILabel *orderedDateLabel = (UILabel *)[cell viewWithTag:kDubbListingCellOrderedDateLabelTag];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:kDubbListingCellAmountLabelTag];
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:kDubbListingCellCategoryLabelTag];

    NSDictionary *orderDetail = orderDetails[indexPath.row];
    if (![orderDetail objectForKey:@"listing"] || [orderDetail[@"listing"] isKindOfClass:[NSNull class]]) {
        [self showMessage:@"Invalid order found"];
        [self.sideMenuViewController presentLeftMenuViewController];
    } else {
        titleLabel.text = [NSString stringWithFormat:@"%@%@",[[orderDetail[@"listing"][@"name"] substringToIndex:1] uppercaseString], [orderDetail[@"listing"][@"name"] substringFromIndex:1]];
        NSDictionary *listingDetail = orderDetail[@"listing"];
        categoryLabel.text = [NSString stringWithFormat:@"%@ > %@", listingDetail[@"category"][@"name"], listingDetail[@"subcategory"][@"name"]];
        opponentType = ([self.userType isEqualToString:@"seller"]) ? @"buyer" : @"seller";
        userNameLabel.text = orderDetail[opponentType][@"username"];
        NSDate *date = [NSDate dateFromString:orderDetail[@"created_at"]];
        orderedDateLabel.text = [NSString stringWithFormat:@"Ordered: %@", [date stringWithFormat:@"MM/dd/yy"]];
        amountLabel.text = [NSString stringWithFormat:@"$%@", orderDetail[@"total_amt"]];
        NSString *imageName = ([orderDetail[@"order_delivery_status"] isEqualToString:@"inprogress"]) ? @"in_progress_indicator.png" : @"complete_indicator.png";
        progressIndicatorImageView.image = [UIImage imageNamed:imageName];
        if ([orderDetail[@"seller"] objectForKey:@"image"] && ![[orderDetail[@"seller"] objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
            [profileImageView sd_setImageWithURL:[NSURL URLWithString:orderDetail[@"seller"][@"image"][@"url"]]];
        }
    }
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DubbOrderConfirmationViewController class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathsForSelectedRows][0];
        NSDictionary *orderDetail = orderDetails[indexPath.row];
        
        DubbOrderConfirmationViewController *vc = segue.destinationViewController;
        vc.userType = self.userType;
        vc.listingInfo = orderDetail[@"listing"];
        vc.purchasedAddOnsDetails = orderDetail[@"details"];
        vc.totalAmountPurchased = [orderDetail[@"total_amt"] integerValue];
        vc.orderID = [NSString stringWithFormat:@"%@", orderDetail[@"details"][0][@"order_id"]];
        vc.userImageURL = ([[orderDetail[@"seller"] objectForKey:@"image"] isKindOfClass:[NSNull class]]) ? @"" : orderDetail[@"seller"][@"image"][@"url"];
        vc.opponentQuickbloxID = orderDetail[opponentType][@"quickblox_id"];
        vc.buyerInfo = orderDetail[@"buyer"];
        vc.orderDeliveryStatus = orderDetail[@"order_delivery_status"];
    }
}
- (IBAction)createListingBarTapped:(id)sender {
    
    [self showCreateListingTableViewController];
    
}

@end
