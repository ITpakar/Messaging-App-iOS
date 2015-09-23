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
#import "TTTAttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ListingTopView.h"
#import "DubbActivityProvider.h"
#import "DubbAddonCell.h"
#import "DubbGigQuantityCell.h"
#import "ChatViewController.h"
#import "DubbOrderConfirmationViewController.h"
#import "DubbSingleListingViewController.h"
#import "AFNetworking.h"
#import "PaypalMobile.h"
#import "AppDelegate.h"

@interface DubbSingleListingViewController () <QBActionStatusDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, PayPalPaymentDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *purchasedAddOns;
    NSMutableArray *addOns;
    NSArray *reviews;
    ListingTopView *topView;
    NSDictionary *baseService;
    NSMutableArray *expansionFlags;
    NSMutableArray *extraQuantityCellIndexPaths;
    MPMoviePlayerController *videoController;
    NSDictionary *sellerInfo;
    NSDictionary *listingInfo;
    CAGradientLayer *maskLayer;
    NSInteger numberOfLinesForHeaderCellDescriptionLabel;
    NSInteger numberOfLinesForReviewContentDescriptionLabel;
    BOOL isAskingQuestion;
    BOOL isDownloading;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *gradientView;

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
    kDubbSingleListingSectionReviewsDescriptionLabelTag,
    kDubbSingleListingSectionSellerIntroductionBackgroundImageViewTag,
    kDubbSingleListingSectionHeaderLocationLabelTag
};
- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)bookNowButtonTapped:(id)sender {
    Boolean isAnonymous = [[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""];
    
    if(isAnonymous){
        [self showLoginView];
    }
    
    if ([[User currentUser].userID integerValue] == [listingInfo[@"user_id"] integerValue]) {
        [self showMessage:@"You can't book your own service!"];
        return;
    }
    
    NSInteger price = 0;
    
    for (NSDictionary * addOnInfo in purchasedAddOns) {
        price += [addOnInfo[@"price"] integerValue];
    }
    
    if (price == 0) {
        [self showMessage:@"Please add 1 more items before clicking Book Now"];
        return;
    }
    
    if (![listingInfo[@"distance"] isKindOfClass:[NSNull class]] && [listingInfo[@"distance"] doubleValue] > [listingInfo[@"radius_mi"] doubleValue]) {

        UIAlertView *msgView = [[UIAlertView alloc] initWithTitle:@"" message:@"You are outside of this seller’s area. Please contact them first before buying." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [msgView setTag:1];
        self.totalPrice = price;
        [msgView show];
    } else {
        [self onPay:listingInfo Price:price];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        [self onPay:listingInfo Price:self.totalPrice];
    }
}

- (IBAction)shareSheetButtonTapped:(id)sender{
    
    NSString *listingTitle = listingInfo[@"name"];
    DubbActivityProvider *activityProvider = [[DubbActivityProvider alloc] initWithListingTitle:listingTitle];
    
    NSArray *objectsToShare = @[activityProvider, listingTitle];
    
    
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
         if (done) {
             NSString *ServiceMsg = @"Message Has Been Shared!";
             [self showMessage:ServiceMsg];
         }
         
         
     }];
    
}

- (IBAction)flagButtonTapped{
    
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
    
    numberOfLinesForHeaderCellDescriptionLabel = 4;
    numberOfLinesForReviewContentDescriptionLabel = 4;
    topView = [[[NSBundle mainBundle] loadNibNamed:@"ListingTopView" owner:nil options:nil] objectAtIndex:0];
    topView.parentViewController = self;
    [topView initViews];
    topView.slideShow.delegate = self;
    [topView.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addParallaxWithView:topView andHeight:sWidth/16*10];
    //[self addScrollingGradientToView:topView];
    
    isAskingQuestion = NO;
    
    __weak DubbSingleListingViewController * weakSelf = self;
    [self.activityIndicator startAnimating];
    [self.backend getListingWithID:self.listingID CompletionHandler:^(NSDictionary *result) {
        [self.activityIndicator stopAnimating];
        
        // Track event
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Browsing"     // Event category (required)
                                                              action:@"View Listing By Id"  // Event action (required)
                                                               label:@"View Listing By Id"          // Event label
                                                               value:nil] build]];    // Event value
        if ([result[@"response"] isKindOfClass:[NSNull class]]) {
            [self showMessage:@"Invalid listing"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        listingInfo = result[@"response"];
        NSMutableArray *images = [NSMutableArray array];
        if ([listingInfo objectForKey:@"videos"] && ![listingInfo[@"videos"] isKindOfClass:[NSNull class]]) {
            [images addObjectsFromArray:listingInfo[@"videos"]];
        }
        [images addObjectsFromArray:listingInfo[@"images"]];
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
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES];
        addOns = [[addOns sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
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
    
    videoController = [[MPMoviePlayerController alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkedAddon:) name:kNotificationDidCheckAddon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uncheckedAddon:) name:kNotificationDidUncheckAddon object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(plusButtonTapped:) name:kNotificationDidTapPlusButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minusButtonTapped:) name:kNotificationDidTapMinusButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playButtonTapped:) name:kNotificationDidTapPlayButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:videoController];
    [self addGradientToView:self.gradientView];
    isDownloading = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [videoController stop];
    [videoController.view removeFromSuperview];
    videoController = nil;
    [topView setDownloadProgress:0];
    isDownloading = NO;
}



#pragma mark - Notification Observers

- (void)playButtonTapped:(NSNotification *)notification {
    NSLog(@"play button tapped");
    if (isDownloading) {
        NSLog(@"is downloading...");
        return;
    }
    NSDictionary *imageInfo = topView.imageInfoSet[topView.slideShow.currentIndex];
    [self downloadVideo:[NSURL URLWithString:imageInfo[@"url"]]];
}
- (void)videoPlayBackDidFinish:(NSNotification *)notification {
    
    // Stop the video player and remove it from view
    [videoController stop];
    [videoController.view removeFromSuperview];
    
    NSLog(@"Finished playback");
    
}
- (void)downloadVideo:(NSURL *)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[url pathComponents].lastObject];
    
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
//    if (fileExists) {
//        videoController.contentURL = [NSURL fileURLWithPath:path];
//        videoController.view.frame = topView.bounds;
//        [topView addSubview:videoController.view];
//        [videoController play];
//        [topView setDownloadProgress:0];
//    } else {
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        videoController.contentURL = [NSURL fileURLWithPath:path];
        videoController.view.frame = topView.bounds;
        [topView addSubview:videoController.view];
        [videoController play];
        [topView setDownloadProgress:0];
        isDownloading = NO;
        NSLog(@"Successfully downloaded file to %@", path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
        [alert show];
        isDownloading = NO;
    }];
    
    [operation start];
    isDownloading = YES;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        NSLog(@"status %f",progress);
        [topView setDownloadProgress:progress];
        
    }];
//    }
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

    Boolean isAnonymous = [[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""];
    
    if(isAnonymous){
        [self showLoginView];
        return;
    }
    
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
    NSString *description = @"Here is where a lovely service description goes describing the talent of the provider and their past experience. Here is where a lovely service description goes describing the talent of the provider and their past experience. Here is where a lovely service description goes describing the talent of the provider and their past experience.";
    switch (indexPath.section) {
        case kDubbSingleListingSectionHeader: {
            if (listingInfo && [listingInfo[@"description"] length] > 0) {
                return 220 + [self heightOfLabelWithText:listingInfo[@"description"] Width:sWidth - 29] - 60 > 220 ? 220 + [self heightOfLabelWithText:listingInfo[@"description"] Width:sWidth - 29] - 60 : 220;
            } else
                return 220;
        }
            
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
                if (numberOfLinesForReviewContentDescriptionLabel == 0) {
                    return 133 + [self heightOfLabelWithText:description Width:sWidth - 29] - 60 > 133 ? 133 + [self heightOfLabelWithText:description Width:sWidth - 29] - 60 : 133;
                } else
                    return 133;
            break;
        default:
            return 44;
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
    
    UILabel *titleLabel    = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderTitleLabelTag];
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderCategoryLabelTag];
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderLocationLabelTag];
    TTTAttributedLabel *descriptionLabel = (TTTAttributedLabel *)[cell viewWithTag:kDubbSingleListingSectionHeaderDescriptionLabelTag];
    
    titleLabel.text = [NSString stringWithFormat:@"%@%@",[[listingInfo[@"name"] substringToIndex:1] uppercaseString], [listingInfo[@"name"] substringFromIndex:1]];
    categoryLabel.text = [[NSString stringWithFormat:@"%@ > %@", listingInfo[@"category"][@"name"], listingInfo[@"subcategory"][@"name"]] uppercaseString];
    descriptionLabel.text = listingInfo[@"description"];
    descriptionLabel.userInteractionEnabled = YES;
    descriptionLabel.lineHeightMultiple = 1.2;
    descriptionLabel.delegate = self;
    descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    descriptionLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    descriptionLabel.extendsLinkTouchArea = YES;
    NSAttributedString *finalString = [[NSAttributedString alloc]
                                       initWithString:@"... more"
                                       attributes:@{
                                                    NSForegroundColorAttributeName : [UIColor colorWithRed:69/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f],
                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0f],
                                                    NSLinkAttributeName : [NSURL URLWithString:@"header"]
                                                    }];
    descriptionLabel.attributedTruncationToken = finalString;
    
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
        NSInteger sequenceNumber = [cell.addonInfo[@"sequence"] integerValue];
        if (sequenceNumber % 2 == 0) {
            cell.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:248.0f/255.0f blue:250.0f/255.0f alpha:1.0];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.titleLabel.hidden = NO;
        cell.addonQuantityContainer.hidden = YES;
        cell.backgroundColor = [UIColor whiteColor];
    }

    cell.quantity = purchasedCount;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%ld", (long)purchasedCount];
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
    NSInteger sequenceNumber = [cell.addonInfo[@"sequence"] integerValue];
    if (sequenceNumber % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:248.0f/255.0f blue:250.0f/255.0f alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

- (UITableViewCell *)configureSellerIntroductionCell {
    
    static NSString *CellIdentifier = @"sellerIntroductionSectionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *backgroundImageView = (UIImageView *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionBackgroundImageViewTag];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionProfileImageViewTag];
    UILabel *nameLabel     = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionUserNameLabelTag];
    UILabel *bioLabel     = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionDescriptionLabelTag];
    UIButton *askQuestionButton = (UIButton *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionAskQuestionButtonTag];
    __weak UILabel *locationLabel = (UILabel *)[cell viewWithTag:kDubbSingleListingSectionSellerIntroductionLocationLabelTag];
    
//    askQuestionButton.enabled = ![[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""];
    
    
    NSDictionary *userInfo = listingInfo[@"user"];
    nameLabel.text = [NSString stringWithFormat:@"%@", userInfo[@"username"]];

    if (![userInfo[@"bio"] isKindOfClass:[NSNull class]]) {
        bioLabel.text = userInfo[@"bio"];
    }
    
    [askQuestionButton addTarget:self action:@selector(askQuestionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat borderWidth = 2.0f;
    profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    profileImageView.layer.borderWidth = borderWidth;
    profileImageView.layer.cornerRadius = 31;
    profileImageView.clipsToBounds = YES;
    if (![[userInfo objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
        [profileImageView sd_setImageWithURL:userInfo[@"image"][@"url"]];
    } else {
        [profileImageView setImage:[UIImage imageNamed:@"placeholder_image.png"]];
    }
    
    NSArray *images = listingInfo[@"images"];
    if (images.count > 1) {
        [backgroundImageView sd_setImageWithURL:images[1][@"url"]];
    } else {
        [backgroundImageView sd_setImageWithURL:images[0][@"url"]];
    }
    
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

    [self addGradientToView:backgroundImageView];
    return cell;
}

- (UITableViewCell *)configureReviewsSectionHeaderCell {
    
    static NSString *CellIdentifier = @"reviewsSectionHeaderCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    AXRatingView *starRatingControl = (AXRatingView *)[cell viewWithTag:kDubbSingleListingSectionReviewsRatingControlTag];
    
    starRatingControl.backgroundColor = [UIColor clearColor];
    starRatingControl.markImage = [UIImage imageNamed:@"star"];
    starRatingControl.stepInterval = 1;
    starRatingControl.value = 5;
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
    starRatingControl.value = 5;
    [starRatingControl setBaseColor:[UIColor lightGrayColor]];
    [starRatingControl setHighlightColor:[UIColor colorWithRed:1.0f green:162.0f/255.0 blue:0 alpha:1.0f]];
    [starRatingControl setUserInteractionEnabled:NO];
    
    
    CGFloat borderWidth = 4.0f;
    profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    profileImageView.layer.borderWidth = borderWidth;
    profileImageView.layer.cornerRadius = 27;
    profileImageView.clipsToBounds = YES;
    TTTAttributedLabel *descriptionLabel = (TTTAttributedLabel *)[cell viewWithTag:kDubbSingleListingSectionReviewsDescriptionLabelTag];
    descriptionLabel.userInteractionEnabled = YES;
    descriptionLabel.lineHeightMultiple = 1.2;
    descriptionLabel.delegate = self;
    descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    NSAttributedString *finalString = [[NSAttributedString alloc]
                                       initWithString:@"... more"
                                       attributes:@{
                                                    NSForegroundColorAttributeName : [UIColor colorWithRed:69/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f],
                                                    NSFontAttributeName : descriptionLabel.font,
                                                    NSLinkAttributeName : [NSURL URLWithString:@"review"]
                                                    }];
    descriptionLabel.attributedTruncationToken = finalString;
    return cell;
    
}

#pragma mark - KASlideShow delegate

- (void)kaSlideShowDidNext:(KASlideShow *)slideShow
{
    [self kaSlideShowDidSlide:slideShow];
}

- (void)kaSlideShowDidPrevious:(KASlideShow *)slideShow
{
    [self kaSlideShowDidSlide:slideShow];
}

- (void)kaSlideShowDidSlide:(KASlideShow *)slideShow {
    if (videoController.view.superview) {
        [videoController stop];
        [videoController.view removeFromSuperview];
    }

    [topView updatePageLabel];
}

#pragma mark - MFMailComposeViewControllerDelegate
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
    
    // Track event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Revenue"     // Event category (required)
                                                          action:@"Purchase"  // Event action (required)
                                                           label:@"Service Purchase"          // Event label
                                                           value:nil] build]];    // Event value
    
    // PURCHASE
    // Google iOS in-app conversion tracking snippet
    // Add this code to the event you'd like to track in your app
    
    [ACTConversionReporter reportWithConversionID:@"942919644" label:@"amfpCLSy-V8Q3J_PwQM" value:@"20.00" isRepeatable:YES];
       
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

#pragma mark - Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    label.numberOfLines = 0;
    if ([[url absoluteString] isEqualToString:@"header"]) {
        numberOfLinesForHeaderCellDescriptionLabel = 0;
    } else {
        numberOfLinesForReviewContentDescriptionLabel = 0;
    }
    
    [self.tableView reloadData];
}

-(void)groupFeedCellDidClickUrl:(NSURL*)urlToOpen
{
    NSLog(@"selected url : %@", urlToOpen);
    [self.view layoutIfNeeded];
    [self.view layoutSubviews];
}


- (void)addGradientToView:(UIView*)view
{
    //add in the gradient to show scrolling
    maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:0.0 alpha:0.0].CGColor;
    
    maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                        (__bridge id)innerColor, nil];
    maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer.bounds = CGRectMake(0, 0,
                                  sWidth,
                                  160);
    maskLayer.anchorPoint = CGPointZero;
    
    [view.layer addSublayer:maskLayer];

}


- (CGFloat)heightOfLabelWithText:(NSString *)text Width:(CGFloat)width {
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, self.view.bounds.size.height)];
    contentLabel.text = text;
    contentLabel.numberOfLines = 0;
    [contentLabel sizeToFit];
    return contentLabel.frame.size.height;
    
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
