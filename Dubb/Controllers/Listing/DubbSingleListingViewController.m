//
//  DubbSingleListingViewController.m
//  Dubb
//
//  Created by andikabijaya on 5/8/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>

#import "UIScrollView+APParallaxHeader.h"
#import "AXRatingView.h"
#import "MBProgressHUD.h"

#import "ListingTopView.h"
#import "DubbAddonCell.h"
#import "DubbGigQuantityCell.h"
#import "ChatViewController.h"
#import "DubbOrderConfirmationViewController.h"
#import "DubbSingleListingViewController.h"

@interface DubbSingleListingViewController () <QBActionStatusDelegate, MFMailComposeViewControllerDelegate>
{
    NSMutableArray *purchasedAddOns;
    NSMutableArray *addOns;
    NSArray *reviews;
    ListingTopView *topView;
    NSDictionary *baseService;
    
    
    NSDictionary *sellerInfo;
    NSDictionary *listingInfo;
    
    BOOL isAskingQuestion;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *bookNowButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DubbSingleListingViewController

enum DubbSingleListingSection {
    kDubbSingleListingSectionHeader = 0,
    kDubbSingleListingSectionGigQuantity,
    kDubbSingleListingSectionAddons,
    kDubbSingleListingSectionSellerIntroduction,
    kDubbSingleListingSectionReviews,
    DubbSingleListingSectionNumber
};

enum DubbSingleListingViewTag {
    kDubbSingleListingSectionHeaderTitleLabelTag = 100,
    kDubbSingleListingSectionHeaderCategoryLabelTag,
    kDubbSingleListingSectionHeaderDescriptionLabelTag,
    kDubbSingleListingSectionAddonsPriceLabelTag,
    kDubbSingleListingSectionAddonsDescriptionLabelTag,
    kDubbSingleListingSectionAddonsMinusButtonTag,
    kDubbSingleListingSectionAddonsQuantityLabelTag,
    kDubbSingleListingSectionAddonsPlusButtonTag,
    kDubbSingleListingSectionSellerIntroductionProfileImageViewTag,
    kDubbSingleListingSectionSellerIntroductionUserNameLabelTag,
    kDubbSingleListingSectionSellerIntroductionLocationLabelTag,
    kDubbSingleListingSectionSellerIntroductionOverallRatingScoreLabelTag,
    kDubbSingleListingSectionSellerIntroductionOverallRatingScoreButtonTag,
    kDubbSingleListingSectionSellerIntroductionDescriptionLabelTag,
    kDubbSingleListingSectionSellerIntroductionAskQuestionButtonTag,
    kDubbSingleListingSectionReviewsRatingControlTag,
    kDubbSingleListingSectionReviewsScoreLabelTag,
    kDubbSingleListingSectionReviewsOverallScoreButtonTag,
    kDubbSingleListingSectionReviewsProfileImageViewTag,
    kDubbSingleListingSectionReviewsUserNameLabelTag,
    kDubbSingleListingSectionReviewsLocationLabelTag,
    kDubbSingleListingSectionReviewsContentRatingControlTag,
    kDubbSingleListingSectionReviewsDescriptionLabelTag
};
- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)bookNowButtonTapped:(id)sender {
    
    if ([[User currentUser].userID isEqualToString:listingInfo[@"user_id"]]) {
        [self showMessage:@"You can't book your own service!"];
        return;
    }
    
    NSMutableArray *purchasedAddOnsDetails = [NSMutableArray array];
    
    for (NSDictionary *purchasedAddOn in purchasedAddOns) {
        
        BOOL exists = NO;
        
        for (NSMutableDictionary *addOnDetail in purchasedAddOnsDetails) {
            if ([addOnDetail[@"addon_id"] isEqualToString:purchasedAddOn[@"id"]]) {
                
                exists = YES;
                addOnDetail[@"quantity"] = [NSString stringWithFormat:@"%ld", [addOnDetail[@"quantity"] integerValue] + 1];
                addOnDetail[@"amount"] = [NSString stringWithFormat:@"%ld", [purchasedAddOn[@"price"] integerValue] * [addOnDetail[@"quantity"] integerValue]];
                break;
                
            }
        }
        
        if (!exists) {
            [purchasedAddOnsDetails addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"addon_id":purchasedAddOn[@"id"],
                                                                                             @"amount":purchasedAddOn[@"price"],
                                                                                             @"quantity":@"1",
                                                                                             @"sequence":purchasedAddOn[@"sequence"],
                                                                                             @"description":purchasedAddOn[@"description"]}]];
        }
        
    }
    
    NSInteger sum = 0;
    
    for (NSDictionary * addOnInfo in purchasedAddOns) {
        sum += [addOnInfo[@"price"] integerValue];
    }
    

    [self.backend createOrder:@{@"total_amt": @(sum),
                                @"listing_id": listingInfo[@"id"],
                                @"buyer_id": [User currentUser].userID,
                                @"seller_id": listingInfo[@"user_id"],
                                @"payment_confirmation_id": @"NA",
                                @"payment_processor_name": @"paypal",
                                @"special_instructions": @"there are no any special instructions",
                                @"details": purchasedAddOnsDetails}
            CompletionHandler:^(NSDictionary *result) {
        
                if (result) {
                    DubbOrderConfirmationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbOrderConfirmationViewController"];
                    vc.listingInfo = listingInfo;
                    vc.purchasedAddOnsDetails = purchasedAddOnsDetails;
                    vc.totalAmountPurchased = sum;
                    vc.orderID = [NSString stringWithFormat:@"%@", result[@"response"][@"id"]];
                    
                    [self.navigationController pushViewController: vc animated:YES];
                } else {
                    [self showMessage:@"Failed to create an order"];
                }
        
    }];
    
}

- (void)flagButtonTapped{
    
    if (![MFMailComposeViewController canSendMail]) {
        [self showMessage:@"Your device can't send Email!"];
        return;
    }

    NSString *postTitle = listingInfo[@"name"];
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
    [mail setSubject:postTitle];
    [mail setMessageBody:[NSString stringWithFormat:@"I'm reporting the content on this listing - \"%@\"", postTitle] isHTML:NO];
    [mail setToRecipients:@[@"tools@dubb.co"]];
    [self presentViewController:mail animated:YES completion:NULL];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    addOns = [NSMutableArray array];
    reviews = [NSArray array];
    purchasedAddOns = [NSMutableArray array];
    [self.view setFrame:self.navigationController.view.bounds];
    
    topView = [[[NSBundle mainBundle] loadNibNamed:@"ListingTopView" owner:nil options:nil] objectAtIndex:0];
    topView.parentViewController = self;
    [topView initViews];
    topView.slideShow.delegate = self;
    [topView.shareSheetButton addTarget:self action:@selector(shareSheetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [topView.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addParallaxWithView:topView andHeight:200];
    
    isAskingQuestion = NO;
    
    __weak DubbSingleListingViewController * weakSelf = self;
    [self.activityIndicator startAnimating];
    [self.backend getListingWithID:self.listingID CompletionHandler:^(NSDictionary *result) {
        [self.activityIndicator stopAnimating];
        listingInfo = result[@"response"];
        NSArray *images = listingInfo[@"images"];
        addOns = [listingInfo[@"addon"] mutableCopy];
        sellerInfo = listingInfo[@"user"];
        
        if ([sellerInfo isKindOfClass:[NSNull class]]) {
            [self showMessage:@"Invalid Listing"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        self.tableView.hidden = NO;
        
        int index = 0;
        for (NSDictionary *addOnInfo in addOns) {
            if ([addOnInfo[@"sequence"] integerValue] == 0) {
                baseService = addOns[index];
                [purchasedAddOns addObject:baseService];
                [addOns removeObjectAtIndex:index];
                break;
            }
            index ++;
        }
        

        
        [topView initImagesWithInfoArray:images];
        
        [weakSelf.tableView reloadData];
        [weakSelf configureBookNowButton];
        
    }];	
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkedAddon:) name:kNotificationDidCheckAddon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncheckedAddon:) name:kNotificationDidUncheckAddon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(plusButtonTapped:) name:kNotificationDidTapPlusButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minusButtonTapped:) name:kNotificationDidTapMinusButton object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkedAddon:(NSNotification *)notif {
    NSDictionary *addOnInfo = notif.userInfo;
    [purchasedAddOns addObject:addOnInfo];
    
    [self configureBookNowButton];
}

- (void) uncheckedAddon:(NSNotification *)notif {
    int index = 0;
    for (NSDictionary *addOnInfo in purchasedAddOns) {
        if ([addOnInfo[@"id"] isEqualToString:notif.userInfo[@"id"]]) {
            [purchasedAddOns removeObjectAtIndex:index];
            break;
        }
        index ++;
    }
    [self configureBookNowButton];
}

- (void) plusButtonTapped:(NSNotification *)notif {
    NSDictionary *addOnInfo = notif.userInfo;
    [purchasedAddOns addObject:addOnInfo];
    
    [self configureBookNowButton];
}

- (void) minusButtonTapped:(NSNotification *)notif {
    
    int index = 0;
    for (NSDictionary *addOnInfo in purchasedAddOns) {
        if ([addOnInfo[@"id"] isEqualToString:notif.userInfo[@"id"]]) {
            [purchasedAddOns removeObjectAtIndex:index];
            break;
        }
        index ++;
    }
    
    [self configureBookNowButton];
}
static bool liked = NO;
- (void)likeButtonTapped {
    
    if (liked) {
        [topView.likeButton setImage:[UIImage imageNamed:@"heart_button_highlighted"] forState:UIControlStateNormal];
    } else {
        [topView.likeButton setImage:[UIImage imageNamed:@"heart_button"] forState:UIControlStateNormal];
    }
    
    liked = !liked;
    
}

- (void)askQuestionButtonTapped:(id)sender {
    
    if (isAskingQuestion == NO) {
        
        isAskingQuestion = YES;
        QBChatDialog *chatDialog = [QBChatDialog new];
        chatDialog.occupantIDs = @[listingInfo[@"user"][@"quickblox_id"]];
        chatDialog.type = QBChatDialogTypePrivate;
        [QBChat createDialog:chatDialog delegate:self];
        
    }
    
    
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result{
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        // dialog created
        
        QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
        
        ChatViewController *chatController = (ChatViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"chatController"];
        chatController.dialog = dialogRes.dialog;
        [self.navigationController pushViewController:chatController animated:YES];
        isAskingQuestion = NO;
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You can't chat with yourself"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)shareSheetButtonTapped {
    
    NSString *textToShare = listingInfo[@"name"];
    NSArray *objectsToShare = @[textToShare];

    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
    [activityVC setCompletionWithItemsHandler:^(NSString *act, BOOL done, NSArray *returnedItems, NSError *activity)
     {
         NSString *ServiceMsg = @"Message Has Been Shared!";
         [self showMessage:ServiceMsg];
         
     }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return DubbSingleListingSectionNumber;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kDubbSingleListingSectionAddons:
            NSLog(@"%ld", (addOns.count == 0) ? 0 : addOns.count + 1);
            return (addOns.count == 0) ? 0 : addOns.count + 1;
        case kDubbSingleListingSectionReviews:
            return 2; //(reviews.count == 0) ? 0 : reviews.count + 1;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kDubbSingleListingSectionHeader:
            return 160;
        case kDubbSingleListingSectionGigQuantity:
            return 45;
        case kDubbSingleListingSectionAddons:
            if (indexPath.row == 0)
                return 37;
            else
                return 45;
        case kDubbSingleListingSectionSellerIntroduction:
            return 165;
        case kDubbSingleListingSectionReviews:
            if (indexPath.row == 0)
                return 90;
            else
                return 133;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case kDubbSingleListingSectionHeader:
            cell = [self configureHeaderCell];
            break;
        case kDubbSingleListingSectionGigQuantity:
            cell = [self configureGigQuantityCell];
            break;
        case kDubbSingleListingSectionAddons:
            if (indexPath.row == 0) {
                cell = [self configureAddonsSectionHeaderCell];
            } else {
                cell = [self configureAddonsSectionContentCellForIndexPath:indexPath];
            }
            break;
        case kDubbSingleListingSectionSellerIntroduction:
            cell = [self configureSellerIntroductionCell];
            break;
        case kDubbSingleListingSectionReviews:
            if (indexPath.row == 0) {
                cell = [self configureReviewsSectionHeaderCell];
            } else {
                cell = [self configureReviewsSectionContentCellForIndexPath:indexPath];
            }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Custom Helpers


// Configure Book Now Button

- (void)configureBookNowButton {
    
    NSInteger sum = 0;
    
    for (NSDictionary * addOnInfo in purchasedAddOns) {
        sum += [addOnInfo[@"price"] integerValue];
    }
    
    [self.bookNowButton setTitle:[NSString stringWithFormat:@"Book Now($%ld)", sum] forState:UIControlStateNormal];
}

// Configure Cells
- (UITableViewCell *)configureHeaderCell {
    
    static NSString *CellIdentifier = @"headerSectionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderTitleLabelTag];
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderCategoryLabelTag];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderDescriptionLabelTag];
    
    titleLabel.text = listingInfo[@"name"];
    categoryLabel.text = [NSString stringWithFormat:@"%@ > %@", listingInfo[@"category"][@"name"], listingInfo[@"subcategory"][@"name"]];
    descriptionLabel.text = listingInfo[@"description"];
    
    return cell;
    
}

- (UITableViewCell *)configureGigQuantityCell {
    
    static NSString *cellIdentifier = @"DubbGigQuantityCell";
    
    DubbAddonCell *cell = (DubbAddonCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DubbGigQuantityCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.addonInfo = baseService;
    return cell;
}

- (UITableViewCell *)configureAddonsSectionHeaderCell {
    
    static NSString *CellIdentifier = @"addonsSectionHeaderCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
    
}

- (UITableViewCell *)configureAddonsSectionContentCellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"DubbAddonCell";
    
    DubbAddonCell *cell = (DubbAddonCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DubbAddonCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell initViewWithAddonInfo:addOns[indexPath.row - 1]];
    return cell;
}

- (UITableViewCell *)configureSellerIntroductionCell {
    
    static NSString *CellIdentifier = @"sellerIntroductionSectionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionProfileImageViewTag];
    UILabel *nameLabel     = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionUserNameLabelTag];
    UIButton *askQuestionButton = (UIButton *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionAskQuestionButtonTag];
    __weak UILabel *locationLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionLocationLabelTag];
    
    NSDictionary *userInfo = listingInfo[@"user"];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfo[@"first"], userInfo[@"last"]];
    
    [askQuestionButton addTarget:self action:@selector(askQuestionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat borderWidth = 4.0f;
    profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    profileImageView.layer.borderWidth = borderWidth;
    profileImageView.layer.cornerRadius = 27;
    profileImageView.clipsToBounds = YES;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[listingInfo[@"lat"] doubleValue] longitude:[listingInfo[@"long"] doubleValue]];
    
    [geocoder reverseGeocodeLocation:location completionHandler: ^ (NSArray  *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks firstObject];
        if(placemark) {

            NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
            NSString *state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
            
            locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];

        }
    }];

    
    return cell;
    
}

- (UITableViewCell *)configureReviewsSectionHeaderCell {
    
    static NSString *CellIdentifier = @"reviewsSectionHeaderCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    AXRatingView *starRatingControl = (AXRatingView *)[cell viewWithTag:kDubbSingleListingSectionReviewsRatingControlTag];
    
    starRatingControl.backgroundColor = [UIColor clearColor];
    starRatingControl.markImage = [UIImage imageNamed:@"star"];
    starRatingControl.stepInterval = 1;
    starRatingControl.value = 3;
    [starRatingControl setBaseColor:[UIColor lightGrayColor]];
    [starRatingControl setHighlightColor:[UIColor colorWithRed:1.0f green:162.0f/255.0 blue:0 alpha:1.0f]];
    [starRatingControl setUserInteractionEnabled:NO];

    return cell;
    
}

- (UITableViewCell *)configureReviewsSectionContentCellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"reviewsSectionContentCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    AXRatingView *starRatingControl = (AXRatingView *)[cell viewWithTag:kDubbSingleListingSectionReviewsContentRatingControlTag];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbSingleListingSectionReviewsProfileImageViewTag];
    
    starRatingControl.backgroundColor = [UIColor clearColor];
    starRatingControl.markImage = [UIImage imageNamed:@"star"];
    starRatingControl.stepInterval = 1;
    starRatingControl.value = 4;
    [starRatingControl setBaseColor:[UIColor lightGrayColor]];
    [starRatingControl setHighlightColor:[UIColor colorWithRed:1.0f green:162.0f/255.0 blue:0 alpha:1.0f]];
    [starRatingControl setUserInteractionEnabled:NO];
    
    
    CGFloat borderWidth = 4.0f;
    profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    profileImageView.layer.borderWidth = borderWidth;
    profileImageView.layer.cornerRadius = 27;
    profileImageView.clipsToBounds = YES;
    return cell;
    
}

#pragma mark - KASlideShow delegate

- (void) kaSlideShowDidNext:(KASlideShow *)slideShow
{
    [topView updatePageLabel];
}

-(void)kaSlideShowDidPrevious:(KASlideShow *)slideShow
{
    [topView updatePageLabel];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            [self showMessage:@"Failed to send Email!"];
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
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
