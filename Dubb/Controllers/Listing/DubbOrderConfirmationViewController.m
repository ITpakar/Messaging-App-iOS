//
//  DubbOrderConfirmationViewController.m
//  Dubb
//
//  Created by andikabijaya on 5/27/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DubbOrderConfirmationViewController.h"
#import <Social/Social.h>

#define commonShareText(listingTitle)  [NSString stringWithFormat:@"I just bought this cool service '%@' on - Dubb Mobile Marketplace for Creative Freelancers - https://itunes.apple.com/it/app/dubb-freelancer-marketplace/id980449775?l=en&mt=8", listingTitle]

enum DubbOrderConfirmationSection {
    kDubbOrderConfirmationSectionHeader = 0,
    kDubbOrderConfirmationSectionAddOn,
    kDubbOrderConfirmationSectionFooter,
    DubbOrderConfirmationSectionNumber
};

enum DubbOrderConfirmationViewTag {
    kDubbOrderConfirmationSectionAddOnTitleLabelTag = 100,
    kDubbOrderConfirmationSectionAddOnQuantityLabelTag,
    kDubbOrderConfirmationSectionAddOnAmountLabelTag,
    kDubbOrderConfirmationSectionFooterTotalAmountLabelTag
};
@interface DubbOrderConfirmationViewController () {
    NSArray *allServices;
}
@property (strong, nonatomic) NSString *listingTitle;
@end
@implementation DubbOrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self initView];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Custom IBActions
- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)upArrowButtonTapped:(id)sender {
    
    self.upArrowButton.hidden = YES;
    [self.view endEditing:YES];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

- (IBAction)shareOnTwitterButtonTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:[NSString stringWithFormat:@"Checkout %@ - @dubbapp creative freelancer marketplace http://www.dubb.com/app", self.listingTitle]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Twitter is not installed on this device! Please install first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}
- (IBAction)shareOnSmsButtonTapped:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[@""];
    NSString *message = commonShareText(self.listingTitle);
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
- (IBAction)shareOnEmailButtonTapped:(id)sender {
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"%@ - Dubb Mobile Marketplace for Creative Freelancers -", self.listingTitle];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"Checkout %@ - @dubbapp creative freelancer marketplace http://www.dubb.com/app", self.listingTitle];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}
- (IBAction)shareOnWhatsAppButtonTapped:(id)sender {
    
    NSString *textToShare = commonShareText(self.listingTitle);
    NSString *textToSend = [NSString stringWithFormat:@"whatsapp://send?text=%@", [textToShare stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *whatsappURL = [NSURL URLWithString:textToSend];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        self.reasonForDisablingMenu = nil;
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Whatsapp is not installed on this device! Please install first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}
- (IBAction)shareOnFacebookButtonTapped:(id)sender {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:commonShareText(self.listingTitle)];
        [self presentViewController:controller animated:YES completion:Nil];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Facebook is not installed on this device! Please install first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}

#pragma mark - MFMessageComposeViewController Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent:
            self.reasonForDisablingMenu = nil;
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            self.reasonForDisablingMenu = nil;
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return DubbOrderConfirmationSectionNumber;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kDubbOrderConfirmationSectionAddOn:
            return self.purchasedAddOnsDetails.count;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case kDubbOrderConfirmationSectionHeader:
            cell = [self configureHeaderCell];
            break;
        case kDubbOrderConfirmationSectionAddOn:
            cell = [self configureAddOnCellForIndexPath:indexPath];
            break;
        case kDubbOrderConfirmationSectionFooter:
            cell = [self configureFooterCell];
            break;
        default:
            break;
    }
    
    return cell;
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
        
        [self addChildViewController:chatController];
        [self.view addSubview:chatController.view];
        [chatController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[chatView]-(0)-|"
                                                                         options:0
                                                                         metrics:nil
                                                                         views:@{@"chatView": chatController.view}]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[shareButtonsContainer]-(20)-[chatView]-(0)-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:@{@"chatView": chatController.view,
                                                                                   @"shareButtonsContainer": self.shareButtonsContainerView}]];
        UIButton *menuButton = (UIButton *)[chatController.view viewWithTag:9876];
        menuButton.hidden = YES;
        [self.view layoutIfNeeded];
        [chatController didMoveToParentViewController:self];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You can't chat with yourself"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
}

#pragma mark - Custom Helpers

- (void)initView {
    
    // Set orderIDLabel text
    self.orderIDLabel.text = [NSString stringWithFormat:@"Order ID #%@", self.orderID];
    
    // Set orderDescriptionLabel text
    if (self.userType && [self.userType isEqualToString:@"seller"]) {
        self.orderDescriptionLabel.text = @"You Have a New Order!";
    } else if (self.orderDeliveryStatus && [self.orderDeliveryStatus isEqualToString:@"completed"]) {
        self.orderDescriptionLabel.text = @"Your Order has been completed!";
    } else {
        self.orderDescriptionLabel.text = @"Your Order is Placed";
    }
    
    
    // Get current date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    NSString *str_date = [dateFormat stringFromDate:[NSDate date]];
    self.orderDateLabel.text = str_date;
    
    self.listingTitle = self.listingInfo[@"name"];
    if ([self.listingInfo[@"user"] objectForKey:@"image"] && ![self.listingInfo[@"user"][@"image"] isKindOfClass:[NSNull class]]) {
        [self.listingImageView sd_setImageWithURL:[NSURL URLWithString:self.listingInfo[@"user"][@"image"][@"url"]] placeholderImage:[UIImage imageNamed:@"placeholder_image.png"]];
    } else if (self.userImageURL && ![self.userImageURL isKindOfClass:[NSNull class]]) {
        [self.listingImageView sd_setImageWithURL:[NSURL URLWithString:self.userImageURL] placeholderImage:[UIImage imageNamed:@"placeholder_image.png"]];
    }
    self.listingTItleLabel.text = self.listingInfo[@"name"];
    [self.listingTItleLabel sizeToFit];
    
    if ([self.userType isEqualToString:@"seller"]) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.buyerInfo[@"lat"] doubleValue] longitude:[self.buyerInfo[@"longitude"] doubleValue]];
        
        [geocoder reverseGeocodeLocation:location completionHandler: ^ (NSArray  *placemarks, NSError *error) {
            
            CLPlacemark *placemark = [placemarks firstObject];
            if(placemark) {
                
                NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
                NSString *state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
                
                NSString *locationString = [NSString stringWithFormat:@"%@, %@", city, state];
                NSString *buyerDescString = [NSString stringWithFormat:@"%@ (%@)", self.buyerInfo[@"username"], locationString];
                
                NSString *text = [NSString stringWithFormat:@"Purchased by: %@", buyerDescString];
                
                NSDictionary *attribs = @{
                                          NSForegroundColorAttributeName: self.listingSellerNameLabel.textColor,
                                          NSFontAttributeName: [UIFont systemFontOfSize:10]
                                          };
                NSMutableAttributedString *attributedText =
                [[NSMutableAttributedString alloc] initWithString:text
                                                       attributes:attribs];
                
                // green text attributes
                UIColor *greenColor = [UIColor colorWithRed:0 green:102/255.0f blue:153.0f/255.0f alpha:1.0f];
                NSRange greenTextRange = [text rangeOfString:buyerDescString];
                [attributedText setAttributes:@{NSForegroundColorAttributeName:greenColor,
                                                NSFontAttributeName: [UIFont systemFontOfSize:10]}
                                        range:greenTextRange];
                
                NSRange boldTextRange = [text rangeOfString:self.buyerInfo[@"username"]];
                [attributedText setAttributes:@{NSForegroundColorAttributeName:greenColor,
                                                NSFontAttributeName: [UIFont boldSystemFontOfSize:10]}
                                        range:boldTextRange];
                
                self.listingSellerNameLabel.attributedText = attributedText;
            }
        }];
    } else {
        self.listingSellerNameLabel.text = ([self.userType isEqualToString:@"seller"]) ? @"" : self.listingInfo[@"user"][@"username"];
    }
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES];
    self.purchasedAddOnsDetails = [[self.purchasedAddOnsDetails sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]] mutableCopy];
    
    
    QBChatDialog *chatDialog = [QBChatDialog new];
    if (self.opponentQuickbloxID)
        chatDialog.occupantIDs = @[self.opponentQuickbloxID];
    else
        chatDialog.occupantIDs = @[_listingInfo[@"user"][@"quickblox_id"]];
    chatDialog.type = QBChatDialogTypePrivate;
    [QBChat createDialog:chatDialog delegate:self];

}

- (UITableViewCell *)configureHeaderCell {
    
    static NSString *CellIdentifier = @"headerCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
    
}

- (UITableViewCell *)configureAddOnCellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"addOnCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *addOnTitleLabel = (UILabel *)[cell viewWithTag:kDubbOrderConfirmationSectionAddOnTitleLabelTag];
    UILabel *addOnQuantityLabel = (UILabel *)[cell viewWithTag:kDubbOrderConfirmationSectionAddOnQuantityLabelTag];
    UILabel *addOnAmountLabel = (UILabel *)[cell viewWithTag:kDubbOrderConfirmationSectionAddOnAmountLabelTag];
    
    NSDictionary *purchasedAddOn = self.purchasedAddOnsDetails[indexPath.row];
    if (([purchasedAddOn objectForKey:@"sequence"] && [purchasedAddOn[@"sequence"] integerValue] == 0) || ([purchasedAddOn objectForKey:@"addon"] && [purchasedAddOn[@"addon"][@"sequence"] integerValue] == 0)) {
        addOnTitleLabel.text = @"Base";
    }
    else {
        if ([purchasedAddOn objectForKey:@"description"]) {
            addOnTitleLabel.text = purchasedAddOn[@"description"];
        } else {
            addOnTitleLabel.text = purchasedAddOn[@"addon"][@"description"];
        }
        
    }
    addOnQuantityLabel.text = purchasedAddOn[@"quantity"];
    addOnAmountLabel.text = [NSString stringWithFormat:@"$%@", purchasedAddOn[@"amount"]];
    
    if (indexPath.row % 2 == 1) {
        cell.backgroundColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f];
    }
    return cell;
    
}

- (UITableViewCell *)configureFooterCell {
    
    static NSString *CellIdentifier = @"footerCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *totalAmountLabel = (UILabel *)[cell viewWithTag:kDubbOrderConfirmationSectionFooterTotalAmountLabelTag];
    totalAmountLabel.text = [NSString stringWithFormat:@"TOTAL: $%ld", self.totalAmountPurchased];
    
    if (self.purchasedAddOnsDetails.count % 2 == 0 ) {
        cell.backgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    }
    return cell;
    
}

-(void)keyboardWillShow:(NSNotification*)aNotification {
    
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    self.upArrowButton.hidden = NO;
    [self.view bringSubviewToFront:self.upArrowButton];
    
}

@end
