//
//  DubbCreateListingTableViewController.m
//  Dubb
//
//  Created by andikabijaya on 3/16/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import <AWSiOSSDKv2/S3.h>
#import "SZTextView.h"
#import "UIImage+fixOrientation.h"
#import "IQKeyboardManager.h"
#import "IQTextView.h"
#import "IQDropDownTextField.h"
#import "DubbServiceDescriptionViewController.h"
#import "DubbServiceAreaViewController.h"
#import "DubbServiceDescriptionWithPriceViewController.h"
#import "DubbCreateListingConfirmationViewController.h"
#import "DubbCreateListingTableViewController.h"

@interface DubbCreateListingTableViewController () <IQDropDownTextFieldDelegate, DubbServiceAreaViewControllerDelegate, UITextViewDelegate>
{
    NSArray *categories;
    NSArray *subCategories;
    NSMutableArray *addOns;
    
    UILabel *currentDescriptionLabel;
    NSInteger currentIndexPathRow;
    BOOL forAddOn;
    BOOL isServiceDescriptionEdited;
    SelectedLocation *selectedLocation;
    NSString *radius;
    
    
}
@property (strong, nonatomic) IBOutlet UILabel *tagsLabel;
@property (strong, nonatomic) IBOutlet UIView *categoryContainerView;
@property (strong, nonatomic) IBOutlet UIView *subcategoryContainerView;

@property (strong, nonatomic) IBOutlet UILabel *fulfillmentInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *fulfillmentAreaLabel;
@property (strong, nonatomic) IBOutlet KASlideShow *slideShow;
@property (strong, nonatomic) IBOutlet UIButton *placeholderButton;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *categoryTextField;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *subCategoryTextField;
@property (strong, nonatomic) IBOutlet SZTextView *serviceDescriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *baseServicePriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *baseServiceDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *serviceDescriptionContainerView;
@property (strong, nonatomic) IBOutlet UIView *fulfillmentInfoContainerView;
@property (strong, nonatomic) IBOutlet UIView *fulfillmentAreaContainerView;
@property (strong, nonatomic) IBOutlet UIView *tagsContainerView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DubbCreateListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;    
    
    addOns = [NSMutableArray array];
    selectedLocation = [[SelectedLocation alloc] init];
    selectedLocation.name = @"Current Location";
    selectedLocation.address = @"";
    selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([[User currentUser].latitude floatValue], [[User currentUser].longitude floatValue]);
    radius = @"100";
    isServiceDescriptionEdited = NO;
    
    [self.serviceDescriptionTextView setPlaceholder:@"                 provide a great local service."];
    UILabel *dollarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 80, 15)];
    dollarLabel.text = @"Hire me to ";
    [self.serviceDescriptionTextView addSubview:dollarLabel];
    self.serviceDescriptionTextView.font = [UIFont systemFontOfSize:16.0f];
    self.serviceDescriptionTextView.delegate = self;
    // Configure a PickerView for selecting a position
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    
    [self.categoryContainerView.layer setCornerRadius:10.0f];
    [self.categoryContainerView.layer setBorderColor:[UIColor colorWithRed:0 green:65/255.0f blue:125.0f/255.0f alpha:1.0f].CGColor];
    [self.categoryContainerView.layer setMasksToBounds:YES];
    [self.categoryContainerView.layer setBorderWidth:1.0f];
    
    [self.subcategoryContainerView.layer setCornerRadius:10.0f];
    [self.subcategoryContainerView.layer setBorderColor:[UIColor colorWithRed:0 green:65/255.0f blue:125.0f/255.0f alpha:1.0f].CGColor];
    [self.subcategoryContainerView.layer setBorderWidth:1.0f];
    [self.subcategoryContainerView.layer setMasksToBounds:YES];
    
    self.categoryTextField.inputAccessoryView = toolbar;
    self.subCategoryTextField.inputAccessoryView = toolbar;
    
    self.categoryTextField.delegate = self;
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"categories/all"];
    [[PHPBackend sharedConnection] accessAPI:apiPath Parameters:nil CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        categories = result[@"response"];
        
        NSMutableArray *categoryNames = [NSMutableArray new];
        for (NSDictionary *category in categories) {
            [categoryNames addObject:category[@"name"]];
        }
        
        [self.categoryTextField setItemList:categoryNames];
    }];
    currentIndexPathRow = -1;
    
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = NO;
    [IQKeyboardManager sharedManager].enable = NO;
    
    [self addTapGestures];
    
    if (self.listingDetail) {
        [self initViewWithValues];
    }
    
}

- (void)initViewWithValues {
//    @{@"name":[NSString stringWithFormat:@"Hire me to %@", self.serviceDescriptionTextView.text],
//      @"instructions":self.fulfillmentInfoLabel.text,
//      @"description":self.baseServiceDescriptionLabel.text,
//      @"category_id":categories[self.categoryTextField.selectedRow][@"id"],
//      @"category_edge_id":subCategories[self.subCategoryTextField.selectedRow][@"category_edge_id"],
//      @"user_id":[User currentUser].userID,
//      @"lat":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.latitude],
//      @"long":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.longitude],
//      @"radius_mi":radius,
//      @"addon":addonArray,
//      @"main_image":imageURLs[0],
//      @"tags":tagsArray
//      };
    NSLog(@"%@", self.listingDetail);
    
    NSArray *addonArray = self.listingDetail[@"addon"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES];
    addonArray = [addonArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    self.serviceDescriptionTextView.text = [self.listingDetail[@"name"] substringFromIndex:11];
    self.serviceDescriptionTextView.text = [self.serviceDescriptionTextView.text stringByReplacingCharactersInRange:NSMakeRange(0,0) withString:@"                 "];
    self.fulfillmentInfoLabel.text = self.listingDetail[@"instructions"];
    self.baseServiceDescriptionLabel.text = self.listingDetail[@"description"];
    self.baseServicePriceLabel.text = [NSString stringWithFormat:@"$%ld", [addonArray[0][@"price"] integerValue]];
    self.categoryTextField.text = self.listingDetail[@"category"][@"name"];
    selectedLocation.name = @"";
    selectedLocation.address = @"";
    selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([self.listingDetail[@"lat"] floatValue], [self.listingDetail[@"long"] floatValue]);
    radius = self.listingDetail[@"radius_mi"];
    addOns = [addonArray mutableCopy];
    [addOns removeObjectAtIndex:0];
    [self.tableView reloadData];
    
}

- (void)addTapGestures {
    UITapGestureRecognizer *serviceDescriptionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editServiceDescription:)];
    [self.serviceDescriptionContainerView addGestureRecognizer:serviceDescriptionTapGestureRecognizer];
    
    UITapGestureRecognizer *fulfillmentInfoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editFulfillmentInfo:)];
    [self.fulfillmentInfoContainerView addGestureRecognizer:fulfillmentInfoTapGestureRecognizer];
    
    UITapGestureRecognizer *fulfillmentAreaTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editFulfillmentArea:)];
    [self.fulfillmentAreaContainerView addGestureRecognizer:fulfillmentAreaTapGestureRecognizer];
    
    UITapGestureRecognizer *tagsTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTags:)];
    [self.tagsContainerView addGestureRecognizer:tagsTapGestureRecognizer];
}

- (void)doneClicked:(UIBarButtonItem*)button {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - IQDropDownTextField delegate

-(void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString*)item
{
    NSInteger selectedRow = textField.selectedRow;
    if (textField == self.categoryTextField) {
        [self.subCategoryTextField setText:@""];
        
        if (selectedRow == -1) return;
        
        NSDictionary *category = [categories objectAtIndex:selectedRow];
        subCategories = category[@"subcategories"];
        
        NSMutableArray *categoryNames = [NSMutableArray new];
        for (NSDictionary *subCategory in subCategories) {
            [categoryNames addObject:subCategory[@"name"]];
        }
        
        [self.subCategoryTextField setItemList:categoryNames];
        
    }
}


#pragma mark - KASlideShow delegate

- (void) kaSlideShowDidNext:(KASlideShow *)slideShow
{
    [self updatePageLabel];
}

-(void)kaSlideShowDidPrevious:(KASlideShow *)slideShow
{
    [self updatePageLabel];
}


#pragma mark - Custom Actions

- (IBAction)editServiceDescription:(id)sender {
    
    [self showDescriptionWithPriceViewControllerWithTitleString:@"Service Description" WithPlaceholderString:@"Hire me to provide a local service" forAddOn:NO];
}

- (IBAction)editFulfillmentArea:(id)sender {
    [self showServiceAreaViewControllerWithTitleString:@"Select a radius and an area"];
}

- (IBAction)editTags:(id)sender {
    [self showDescriptionViewControllerWithTitleString:@"Tags" WithPlaceholderString:@"Add a minimum of three tags to describe your service.(separated by commas).(E.g. photographer, outdoors, family)" WithCurrentDescriptionLabel:self.tagsLabel];
}

- (IBAction)editFulfillmentInfo:(id)sender {
    
    [self showDescriptionViewControllerWithTitleString:@"Fulfillment Info" WithPlaceholderString:@"What information you need from buyers in order to provide your service." WithCurrentDescriptionLabel:self.fulfillmentInfoLabel];
    
}

- (void) showDescriptionViewControllerWithTitleString:(NSString *)titleString WithPlaceholderString:(NSString *)placeholderString WithCurrentDescriptionLabel:(UILabel *)descriptionLabel {
    DubbServiceDescriptionViewController *dubbServiceDescriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbServiceDescriptionViewController"];
    dubbServiceDescriptionViewController.delegate = self;
    dubbServiceDescriptionViewController.titleString = titleString;
    dubbServiceDescriptionViewController.placeholderString = placeholderString;
    currentDescriptionLabel = descriptionLabel;
    dubbServiceDescriptionViewController.descriptionString = currentDescriptionLabel.text;
    [self.navigationController pushViewController:dubbServiceDescriptionViewController animated:YES];
}

- (void) showServiceAreaViewControllerWithTitleString:(NSString *)titleString{
    DubbServiceAreaViewController *dubbServiceAreaViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbServiceAreaViewController"];
    dubbServiceAreaViewController.delegate = self;
    dubbServiceAreaViewController.titleString = titleString;
    [self.navigationController pushViewController:dubbServiceAreaViewController animated:YES];
}

- (void) showDescriptionWithPriceViewControllerWithTitleString:(NSString *)titleString WithPlaceholderString:(NSString *)placeholderString forAddOn:(BOOL)isForAddOn {
    DubbServiceDescriptionWithPriceViewController *dubbServiceDescriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbServiceDescriptionWithPriceViewController"];
    dubbServiceDescriptionViewController.delegate = self;
    dubbServiceDescriptionViewController.titleString = titleString;
    dubbServiceDescriptionViewController.placeholderString = placeholderString;
    
    forAddOn = isForAddOn;
    if (forAddOn) {
        dubbServiceDescriptionViewController.addOns = addOns;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        dubbServiceDescriptionViewController.currentIndex = (selectedIndexPath.row < addOns.count) ? selectedIndexPath.row : -1;
    } else {
        dubbServiceDescriptionViewController.currentIndex = -2;
        if (isServiceDescriptionEdited) {
            
            dubbServiceDescriptionViewController.baseServicePrice = self.baseServicePriceLabel.text;
            dubbServiceDescriptionViewController.baseServiceDescription = self.baseServiceDescriptionLabel.text;
        }
    }
    [self.navigationController pushViewController:dubbServiceDescriptionViewController animated:YES];
}

- (void) completedWithDescription:(NSString*)description WithPrice:(NSString *)price {
    if (!forAddOn) {

        [self.baseServicePriceLabel setText:[NSString stringWithFormat:@"%@", price]];
        [self.baseServiceDescriptionLabel setText:description];
        isServiceDescriptionEdited = YES;
    } else {
        [self.tableView reloadData];
    }
}
- (void) completedWithDescription:(NSString*)description {
    currentDescriptionLabel.text = description;
}

- (void) completedWithRadius:(NSString*)radiusString WithLocation:(SelectedLocation *)location {
    radius = radiusString;
    selectedLocation = location;
    self.fulfillmentAreaLabel.text = [NSString stringWithFormat:@"%@ mile from %@", radius, location.address];
}
- (IBAction)menuButtonTapped:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}
- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)nextButtonTapped:(id)sender {
    [self.slideShow next];
    
}
- (IBAction)deleteButtonTapped:(id)sender {
    
    if (self.chosenImages.count > 1) {
        [self.slideShow removeObjectFromImagesAtIndex:self.slideShow.currentIndex];
        [self updatePageLabel];
        
    } else {
        [self.chosenImages removeAllObjects];
        [self.placeholderButton setHidden:NO];
    }
}

- (IBAction)prevButtonTapped:(id)sender {
    [self.slideShow previous];
}

- (IBAction)submitButtonTapped:(id)sender {
    
    NSString* title = self.serviceDescriptionTextView.text;
    NSString* tags = self.tagsLabel.text;
    

    if (title.length <= 0) {
        [self showMessage:@"Please enter the title for this listing"];
        return;
    }
    
    if (self.categoryTextField.selectedRow == -1 || self.subCategoryTextField.selectedRow == -1) {
        [self showMessage:@"Please select one category."];
    }
    
    if (tags.length <= 0 || [tags componentsSeparatedByString:@","].count < 3) {
        
        [self showMessage:@"Please add minimum 3 tags separated with commas."];
        return;
    }
    
    if (self.baseServiceDescriptionLabel.text.length <= 0) {
        [self showMessage:@"Please describe your base service."];
        return;
    }
    
    if ([[self.baseServicePriceLabel.text substringFromIndex:1] intValue] <= 0) {
        [self showMessage:@"Please describe your base service price correctly."];
        return;
    }
    
    if (self.chosenImages.count <= 0) {
        [self showMessage:@"Please select at least one image."];
        return;
    }
    
    NSMutableArray *imageURLs = [self uploadImages];
    NSArray *tagsArray = [self.tagsLabel.text componentsSeparatedByString:@","];
    NSMutableArray *addonArray = [NSMutableArray arrayWithArray:addOns];
    [addonArray addObject:@{@"description":self.baseServiceDescriptionLabel.text, @"price":[self.baseServicePriceLabel.text substringFromIndex:1], @"sequence":@"0"}];
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"listing"];
    [self showProgress:@"Wait for a moment"];
    
    NSDictionary *params;
    
    NSMutableArray *imagesWithoutMainImage = [imageURLs mutableCopy];
    if (imagesWithoutMainImage.count == 1) {
        params = @{@"name":[NSString stringWithFormat:@"Hire me to %@", self.serviceDescriptionTextView.text],
                   @"instructions":self.fulfillmentInfoLabel.text,
                   @"description":self.baseServiceDescriptionLabel.text,
                   @"category_id":categories[self.categoryTextField.selectedRow][@"id"],
                   @"category_edge_id":subCategories[self.subCategoryTextField.selectedRow][@"category_edge_id"],
                   @"user_id":[User currentUser].userID,
                   @"lat":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.latitude],
                   @"long":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.longitude],
                   @"radius_mi":radius,
                   @"addon":addonArray,
                   @"main_image":imageURLs[0],
                   @"tags":tagsArray
                   };
    } else {
        [imagesWithoutMainImage removeObjectAtIndex:0];
        params = @{@"name":[NSString stringWithFormat:@"Hire me to %@", self.serviceDescriptionTextView.text],
                             @"instructions":self.fulfillmentInfoLabel.text,
                             @"description":self.baseServiceDescriptionLabel.text,
                             @"category_id":categories[self.categoryTextField.selectedRow][@"id"],
                             @"category_edge_id":subCategories[self.subCategoryTextField.selectedRow][@"category_edge_id"],
                             @"user_id":[User currentUser].userID,
                             @"lat":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.latitude],
                             @"long":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.longitude],
                             @"radius_km":radius,
                             @"addon":addonArray,
                             @"main_image":imageURLs[0],
                             @"images":imagesWithoutMainImage,
                             @"tags":tagsArray
                             };
    
    }
    
    [[PHPBackend sharedConnection] accessAPIbyPost:apiPath
                                        Parameters:params
                                 CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
                                     [self hideProgress];
                                     if (result) {
                                         [self performSegueWithIdentifier:@"displayCreateListingConfirmationSegue" sender:nil];
                                     }
                                 }];
    
    
}

- (IBAction)launchController
{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
    elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
    
    elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[[dict objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
                [images addObject:image];
                
            }
            
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    
    self.chosenImages = images;
    [self.placeholderButton setHidden:YES];
    
    [self initSlideShow];
    
    
}
- (void)initSlideShow {
    
    self.slideShow.delegate = self;
    [self.slideShow setTransitionType:KASlideShowTransitionSlide]; // Choose a transition type (fade or slide)
    [self.slideShow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    [self.slideShow addGesture:KASlideShowGestureSwipe];
    
    [self updateSlideShow];
    [self updatePageLabel];
    
}

- (void)updateSlideShow {
    
    [self.slideShow setImagesDataSource:self.chosenImages];
}

-(void)updatePageLabel {
    
    [self.pageLabel setText:[NSString stringWithFormat:@"%lu(%lu)", self.slideShow.currentIndex + 1, (unsigned long)self.chosenImages.count]];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)submitTagInfoWithListingID:(NSString *)listingID{
    
    NSArray *tagsArray = [self.tagsLabel.text componentsSeparatedByString:@","];
    for (NSString *tag in tagsArray) {
        NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"tag"];
        [[PHPBackend sharedConnection] accessAPIbyPost:apiPath
                                            Parameters:@{@"name":tag,
                                                         @"user_id":[User currentUser].userID
                                                         }
                                     CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
                                         
                                     }];
    }
    
}
- (NSMutableArray *) uploadImages{
    
    NSMutableArray *imageURLs = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (UIImage *image in self.chosenImages) {
        
        NSData *data = UIImageJPEGRepresentation(image, 0.7);
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
        NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        
        [fileManager createFileAtPath:tempFilePath contents:data attributes:nil];
        [imageURLs addObject:[NSString stringWithFormat:@"http://s3-us-west-1.amazonaws.com/listing-image-uploads/completed/%@", fileName]];
        [self uploadFileWithFileName:fileName SourcePath:tempFilePath];
    }
    
    return imageURLs;
}

- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath {
    
    NSURL *fullPath = [NSURL fileURLWithPath:sourcePath
                                 isDirectory:NO];
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"listing-image-uploads";
    uploadRequest.key = [NSString stringWithFormat:@"completed/%@", fileName];
    uploadRequest.body = fullPath;
    uploadRequest.contentType = @"image/jpeg";
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        NSLog(@"Fail %@", task.error);
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
            
            //Uploading image fails
            
        }
        
        if (task.result) {
            
            // The file uploaded successfully.
            
            NSLog(@"Success: %@", task.result);
        }
        return nil;
    }];
    
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 2;
    
    if (addOns.count > 1) {
        numberOfRows = addOns.count < 5 ? addOns.count + 1 : addOns.count;
    } else {
        numberOfRows = 2;
    }
    return numberOfRows;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddOnCell"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddOnCell"];
    
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:101];
    currentIndexPathRow = indexPath.row;
    
    if (indexPath.row == [self.tableView numberOfRowsInSection:0] - 1 && addOns.count < 5) {
        priceLabel.hidden = YES;
        descriptionLabel.text = @"Add another add-on";
    } else {
        priceLabel.hidden = NO;
        if (addOns.count > 0) {
            NSDictionary *addOn = addOns[indexPath.row];
            [priceLabel setText:[NSString stringWithFormat:@"$%ld", [addOn[@"price"] integerValue]]];
            [descriptionLabel setText:addOn[@"description"]];
        } else if (addOns.count == 0 && indexPath.row == 0) {
            [priceLabel setText:@"$40"];
            [descriptionLabel setText:@"Describe your add - on"];
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < addOns.count) {
        return YES;
    }
    
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [addOns removeObjectAtIndex:indexPath.row];
        if (addOns.count > 0 && indexPath.row < addOns.count) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView reloadData];
        }

    }
}
#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 43;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showDescriptionWithPriceViewControllerWithTitleString:@"Add On" WithPlaceholderString:@"Hire me to provide a great local service." forAddOn:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITextView Delegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    if (textView.selectedRange.location < 17) {
        textView.selectedRange = NSMakeRange(17, 0);
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"displayCreateListingConfirmationSegue"]) {
        DubbCreateListingConfirmationViewController *viewController = segue.destinationViewController;
        
        NSString *string = self.serviceDescriptionTextView.text;
        viewController.listingTitle = string;
        viewController.listingLocation = selectedLocation;
        viewController.mainImage = self.chosenImages[0];
        viewController.categoryDescription = [NSString stringWithFormat:@"%@ / %@", self.categoryTextField.text, self.subCategoryTextField.text];

    }
}

@end
