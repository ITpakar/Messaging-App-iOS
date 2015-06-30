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


#import "PaypalMobile.h"
#import "AppDelegate.h"

@interface DubbSingleListingViewController () <QBActionStatusDelegate, MFMailComposeViewControllerDelegate, PayPalPaymentDelegate>
{
    NSMutableArray *purchasedAddOns;
    NSMutableArray *addOns;
    NSArray *reviews;
    ListingTopView *topView;
    NSDictionary *baseService;
    NSMutableArray *expansionFlags;
    NSMutableArray *extraQuantityCellIndexPaths;
    
    NSDictionary *sellerInfo;
    NSDictionary *listingInfo;
    
    BOOL isAskingQuestion;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
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
    
    if ([[User currentUser].userID integerValue] == [listingInfo[@"user_id"] integerValue]) {
        [self showMessage:@"You can't book your own service!"];
        return;
    }
    
    NSInteger price = 0;
    
    for (NSDictionary * addOnInfo in purchasedAddOns) {
        price += [addOnInfo[@"price"] integerValue];
    }
    
    [self onPay:listingInfo Price:price];
    
    
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
        for (int i = 0; i < addOns.count; i++) {
            
            [expansionFlags setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:i];
            
        }
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
    expansionFlags = [NSMutableArray array];
    extraQuantityCellIndexPaths = [NSMutableArray array];
    
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

    
    [expansionFlags setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:[addOnInfo[@"sequence"] integerValue] - 1];
    [self showNewExtraQuantityCellAtIndex:[self calculateIndexPathWithAddonInfo:addOnInfo]];

    [self configureBookNowButton];
}

- (void) uncheckedAddon:(NSNotification *)notif {

    for (int i=0;i<[purchasedAddOns count]; i++) {
        NSDictionary *addOnInfo = [purchasedAddOns objectAtIndex:i];
        if ([addOnInfo[@"id"] isEqualToString:notif.userInfo[@"id"]]) {
            [purchasedAddOns removeObject:addOnInfo];
            i--;
        }
    }
    if ([expansionFlags[[notif.userInfo[@"sequence"] integerValue] - 1] boolValue]) {
        [expansionFlags setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:[notif.userInfo[@"sequence"] integerValue] - 1];
        [self hideExtraQuantityCellAtIndexPath:[self calculateIndexPathWithAddonInfo:notif.userInfo]];

    }
    
    [self configureBookNowButton];
}


- (NSIndexPath *)calculateIndexPathWithAddonInfo:(NSDictionary *)addonInfo {
    
    NSInteger sequenceNumber = [addonInfo[@"sequence"] integerValue];
    
    int r = 1, c = 0;
    
    while (c < sequenceNumber - 1) {
        
        if ([expansionFlags[c++] boolValue]) {
            
            r += 2;
            
        } else {
            
            r ++;
            
        }
        
    }
    
    
    return [NSIndexPath indexPathForRow:r inSection:kDubbSingleListingSectionAddons];
    
    
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

    NSInteger expandedRowCount = 0;
    switch (section) {
        case kDubbSingleListingSectionAddons:
            

            for (NSNumber *expansionFlag in expansionFlags) {
                
                if ([expansionFlag boolValue]) {
                    expandedRowCount ++;
                }
            
                
            }
            return (addOns.count == 0) ? 0 : addOns.count + expandedRowCount + 1;
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
            return 200;
        case kDubbSingleListingSectionGigQuantity:
            return 45;
        case kDubbSingleListingSectionAddons:
            if (indexPath.row == 0)
                return 37;
            else
                return 45;
        case kDubbSingleListingSectionSellerIntroduction:
            return 232;
        case kDubbSingleListingSectionReviews:
            if (indexPath.row == 0)
                return 44;
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
            cell = [self configureGigQuantityCellWithTitle:@"Gig Quantity" WithAddonInfo:baseService];
            break;
        case kDubbSingleListingSectionAddons:
            if (indexPath.row == 0) {
                
                cell = [self configureAddonsSectionHeaderCell];
                
            } else {
                
                int c = 0, r = 1;
                
                while (r < indexPath.row) {
                    
                    if ([expansionFlags[c++] boolValue]) {
                        
                        r += 2;
                        
                    } else {
                        
                        r ++;
                        
                    }
                    
                }
                

                if (r == indexPath.row) {
                    
                    cell = [self configureAddonsSectionContentCellForIndexPath:[NSIndexPath indexPathForRow:c inSection:kDubbSingleListingSectionAddons]];
                    
                } else {
                    
                    cell = [self configureGigQuantityCellWithTitle:@"Extra Quantity" WithAddonInfo:addOns[c - 1]];
                    
                }
                
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDubbSingleListingSectionAddons && indexPath.row > 0) {
        
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[DubbAddonCell class]]) {
            
            DubbAddonCell *addonCell = (DubbAddonCell *)cell;
            if ([[expansionFlags objectAtIndex:[addonCell.addonInfo[@"sequence"] integerValue] - 1] boolValue]) {
                
                // if expanded
                
                
                
                [expansionFlags setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:[addonCell.addonInfo[@"sequence"] integerValue] - 1];
                [self hideExtraQuantityCellAtIndexPath:indexPath];
                
                
                
            } else {
                
                // if collapsed
                
                BOOL exists = NO;
                for (NSDictionary *purchasedAddOn in purchasedAddOns) {
                    
                    if ([addonCell.addonInfo[@"id"] isEqualToString:purchasedAddOn[@"id"]]) {
                        
                        exists = YES;
                        break;
                        
                    }
                    
                }
                if (!exists) {
                    [purchasedAddOns addObject:addonCell.addonInfo];
                    [self configureBookNowButton];
                }
                [expansionFlags setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:[addonCell.addonInfo[@"sequence"] integerValue] - 1];
                [self showNewExtraQuantityCellAtIndex:indexPath];
                
                
            }
            
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Custom Helpers


// Configure Book Now Button

- (void)configureBookNowButton {
    
    NSInteger sum = 0;
    
    for (NSDictionary * addOnInfo in purchasedAddOns) {
        sum += [addOnInfo[@"price"] integerValue];
    }
    
    [self.totalPriceLabel setText:[NSString stringWithFormat:@"$%ld", sum]];
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

- (UITableViewCell *)configureGigQuantityCellWithTitle:(NSString *)titleString WithAddonInfo:(NSDictionary *)addonInfo {
    
    static NSString *cellIdentifier = @"DubbGigQuantityCell";
    
    DubbGigQuantityCell *cell = (DubbGigQuantityCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DubbGigQuantityCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.addonInfo = addonInfo;
    
    NSInteger purchasedCount = 0;
    for (NSDictionary *purchasedAddon in purchasedAddOns) {
        
        if ([purchasedAddon[@"id"] isEqualToString:addonInfo[@"id"]]) {
            purchasedCount ++;
        }
        
    }
    if ([titleString isEqualToString:@"Extra Quantity"]) {
        cell.titleLabel.hidden = YES;
        cell.addonQuantityContainer.hidden = NO;
        cell.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:248.0f/255.0f blue:250.0f/255.0f alpha:1.0];
    } else {
        cell.titleLabel.hidden = NO;
        cell.addonQuantityContainer.hidden = YES;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.quantity = purchasedCount;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%ld", purchasedCount];
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
    
    [cell initViewWithAddonInfo:addOns[indexPath.row]];
    return cell;
}

- (UITableViewCell *)configureSellerIntroductionCell {
    
    static NSString *CellIdentifier = @"sellerIntroductionSectionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionProfileImageViewTag];
    UILabel *nameLabel     = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionUserNameLabelTag];
    UIButton *askQuestionButton = (UIButton *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionAskQuestionButtonTag];
    __weak UILabel *locationLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionLocationLabelTag];
    askQuestionButton.enabled = ![[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""];
    
    
    NSDictionary *userInfo = listingInfo[@"user"];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfo[@"first"], userInfo[@"last"]];
    
    [askQuestionButton addTarget:self action:@selector(askQuestionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat borderWidth = 2.0f;
    profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    profileImageView.layer.borderWidth = borderWidth;
    profileImageView.layer.cornerRadius = 31;
    profileImageView.clipsToBounds = YES;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[listingInfo[@"lat"] doubleValue] longitude:[listingInfo[@"longitude"] doubleValue]];
    
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

#pragma mark -
#pragma mark Payment


-(void) onPay:(NSDictionary *)listing Price:(NSInteger) price
{
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lu", price]];
    payment.currencyCode = @"USD";
    payment.shortDescription = [NSString stringWithFormat:@"%@ (%@)", listing[@"name"], listing[@"user"][@"username"] ];
    payment.items = nil;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = nil; // if not including payment details, then leave payment.paymentDetails as nil
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:app.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
    
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {

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
    
    NSLog(@"PayPal Payment Success!\n %@", [completedPayment description]);
       
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self showProgress:@"Creating Order..."];
    [self.backend createOrder:@{@"total_amt": @(sum),
                                @"listing_id": listingInfo[@"id"],
                                @"buyer_id": [User currentUser].userID,
                                @"seller_id": listingInfo[@"user_id"],
                                @"payment_confirmation_id": [completedPayment.confirmation[@"response"] objectForKey:@"id"],
                                @"payment_processor_name": @"paypal",
                                @"special_instructions": completedPayment.description,
                                @"details": purchasedAddOnsDetails }
            CompletionHandler:^(NSDictionary *result) {

                [self hideProgress];
                if (result) {
                    DubbOrderConfirmationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbOrderConfirmationViewController"];
                    vc.listingInfo = listingInfo;
                    vc.purchasedAddOnsDetails = purchasedAddOnsDetails;
                    vc.totalAmountPurchased = sum;
                    vc.orderID = [NSString stringWithFormat:@"%@", result[@"response"][@"id"]];
                    [[iRate sharedInstance] promptIfNetworkAvailable];
                    [self.navigationController pushViewController: vc animated:YES];
                } else {
                    [self showMessage:[NSString stringWithFormat:@"Sorry, server is not responding, please contact administrator to confirm payment.\nYour payment id: %@", [completedPayment.confirmation[@"response"] objectForKey:@"id"]]];
                }
                
            }];
    
    
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    [self showMessage:@"Payment cancelled"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}

- (void)hideExtraQuantityCellAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:kDubbSingleListingSectionAddons]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    
}

- (void)showNewExtraQuantityCellAtIndex:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:kDubbSingleListingSectionAddons];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (BOOL)checkIfExpandedForIndexPath:(NSIndexPath *)indexPath {
    
    
    return NO;
    
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
