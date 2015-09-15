//
//  DubbCreateListingTableViewController.m
//  Dubb
//
//  Created by andikabijaya on 3/16/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AWSiOSSDKv2/S3.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SZTextView.h"
#import "UIImage+fixOrientation.h"
#import "IQKeyboardManager.h"
#import "TLTagsControl.h"
#import "IQTextView.h"
#import "GKImagePicker.h"
#import "IQDropDownTextField.h"
#import "DubbServiceDescriptionViewController.h"
#import "DubbServiceAreaViewController.h"
#import "DubbServiceDescriptionWithPriceViewController.h"
#import "DubbCreateListingConfirmationViewController.h"
#import "ListingImageView.h"
#import "DubbCreateListingTableViewController.h"

NSString *const apiKey = @"AIzaSyBqO1R2q7YGqnEAegFiA4vbHo7oLn8IqV0";
#define MAX_CHARACTER_NUMBER_BASE  510
#define MAX_CHARACTER_NUMBER_ADDON 100
typedef NS_ENUM(NSUInteger, TableViewSection){
    TableViewSectionCurrentLocation,
    TableViewSectionMain,
    TableViewSectionCount
};

@interface DubbCreateListingTableViewController () <UINavigationControllerDelegate, IQDropDownTextFieldDelegate, GKImagePickerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>
{
    NSArray *categories;
    NSArray *subCategories;
    NSMutableArray *addOns;
    NSMutableArray *assetArray;
    NSMutableArray *originalAddonArray;
    NSMutableArray *listingImageViewArray;
    NSMutableArray *listingThumbnailViewArray;
    NSArray *originalImageArray;
    NSArray *originalVideoArray;
    NSArray *originalTagArray;
    UILabel *currentDescriptionLabel;
    NSInteger currentIndexPathRow;
    BOOL forAddOn;
    BOOL isServiceDescriptionEdited;
    SelectedLocation *selectedLocation;
    NSString *radius;
    NSString *baseServiceID;
    UITextField *prevFocusedTextField;
    UIToolbar *addonToolbar;
}
@property (strong, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (strong, nonatomic) IBOutlet TLTagsControl *tagsControl;
@property (strong, nonatomic) IBOutlet UILabel *imagesCountLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (strong, nonatomic) IBOutlet UILabel *videosCountLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *videosScrollView;
@property (strong, nonatomic) IBOutlet SZTextView *fulfillmentInfoTextView;
@property (strong, nonatomic) IBOutlet UITextField *radiusTextField;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *categoryTextField;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *subCategoryTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet SZTextView *baseServiceDescriptionTextView;
@property (strong, nonatomic) IBOutlet UITextField *baseServicePriceTextField;
@property (strong, nonatomic) IBOutlet UILabel *availableCharacterNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *availableCharacterNumberLabelForAddon;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *locationSearchTableView;
@property (strong, nonatomic) GKImagePicker *picker;
@end

@implementation DubbCreateListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.base_max_price = 100;
    self.base_min_price = 0;
    self.addon_max_price = 100;
    self.addon_min_price = 0;
    [self getPricingLimits];

    self.localSearchQueries = [NSMutableArray array];
    self.pastSearchWords = [NSMutableArray array];
    self.pastSearchResults = [NSMutableArray array];
    self.searchTextField.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;    
    
    _listingImages = [NSMutableArray array];
    _listingVideos = [NSMutableArray array];
    addOns = [NSMutableArray array];
    originalAddonArray = [NSMutableArray array];
    selectedLocation = [[SelectedLocation alloc] init];
    selectedLocation.name = @"Current Location";
    selectedLocation.address = @"";
    selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([[User currentUser].latitude floatValue], [[User currentUser].longitude floatValue]);
    radius = @"100";
    isServiceDescriptionEdited = NO;
    
    UILabel *dollarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, self.baseServicePriceTextField.frame.size.height)];
    dollarLabel.text = @"$";
    dollarLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.baseServicePriceTextField.leftView = dollarLabel;
    self.baseServicePriceTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *hireMeToLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, self.titleTextField.frame.size.height)];
    hireMeToLabel.text = @"Hire me to ";
    hireMeToLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.titleTextField.leftView = hireMeToLabel;
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    
    // Configure a PickerView for selecting a position
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    
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
        
        if (self.listingDetail) {
            for (int i = 0; i < categoryNames.count; i++) {
                if ([self.listingDetail[@"category"][@"name"] isEqualToString:categoryNames[i]]) {
                    self.categoryTextField.selectedRow = i + 1;
                    NSDictionary *category = [categories objectAtIndex:i];
                    subCategories = category[@"subcategories"];
                    
                    NSMutableArray *subCategoryNames = [NSMutableArray new];
                    for (NSDictionary *subCategory in subCategories) {
                        [subCategoryNames addObject:subCategory[@"name"]];
                    }
                    
                    [self.subCategoryTextField setItemList:subCategoryNames];
                    for (int j = 0; j < subCategoryNames.count; j++) {
                        
                        if ([self.listingDetail[@"subcategory"][@"name"] isEqualToString:subCategoryNames[j]]) {
                            
                            self.subCategoryTextField.selectedRow = j + 1;
                            break;
                        }
                    }
                    break;
                    
                }
            }
        }
        
    }];
    currentIndexPathRow = -1;
    
    self.tagsControl.tags = [NSMutableArray array];
    self.tagsControl.tagPlaceholder = @"Add a new tag here";
    self.tagsControl.tagsBackgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1];
    self.tagsControl.tagsTextColor = [UIColor whiteColor];
    
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = NO;
    [IQKeyboardManager sharedManager].enable = NO;
    
    
    [self.fulfillmentInfoTextView setPlaceholder:@"What information you need from buyers in order to provide your services (dates, number of attendees, location, parking, entrance information, etc.)"];
    [self.baseServiceDescriptionTextView setPlaceholder:@"Provide an explanation of what are you offering."];
    if (self.listingDetail) {
        [self initViewWithValues];
    }
    [addOns addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"description":@"", @"price":@""}]];
    [self setupImagesScrollView];
    [self setupVideosScrollView];
    [self.availableCharacterNumberLabel setText:[NSString stringWithFormat:@"%ld", MAX_CHARACTER_NUMBER_BASE - [self.baseServiceDescriptionTextView.text length]]];
    
}

- (void)initViewWithValues {

    NSLog(@"%@", self.listingDetail);
    
    NSArray *addonArray = self.listingDetail[@"addon"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES];
    addonArray = [addonArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    self.navigationTitleLabel.text = @"Edit Listing";
    [self.doneButton setTitle:@"Save" forState:UIControlStateNormal];
    self.titleTextField.text = self.listingDetail[@"name"];
    self.fulfillmentInfoTextView.text = self.listingDetail[@"instructions"];
    self.baseServiceDescriptionTextView.text = self.listingDetail[@"description"];
    self.baseServicePriceTextField.text = [NSString stringWithFormat:@"%ld", [addonArray[0][@"price"] integerValue]];
    self.categoryTextField.text = self.listingDetail[@"category"][@"name"];

    baseServiceID = addonArray[0][@"id"];
    selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([self.listingDetail[@"lat"] floatValue], [self.listingDetail[@"longitude"] floatValue]);
    radius = ([self.listingDetail[@"radius_mi"] integerValue] > 0) ?  self.listingDetail[@"radius_mi"] : [NSString stringWithFormat:@"%.3f", [self.listingDetail[@"radius_km"] integerValue] * 0.621371192];
    addOns = [addonArray mutableCopy];
    [addOns removeObjectAtIndex:0];
    originalAddonArray = [addonArray mutableCopy];
    [self.tableView reloadData];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.listingDetail[@"lat"] floatValue] longitude:[self.listingDetail[@"longitude"] floatValue]];
    
    [geocoder reverseGeocodeLocation:location completionHandler: ^ (NSArray  *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks firstObject];
        if(placemark) {
            
            NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
            NSString *state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
            
            NSString *locationString = [NSString stringWithFormat:@"%@, %@", city, state];
            selectedLocation.name = city;
            selectedLocation.address = locationString;
            self.searchTextField.text = selectedLocation.address;
            self.radiusTextField.text = radius;
            
        }
    }];
    
    // initialize with images
    
    originalImageArray = self.listingDetail[@"images"];
    [self downloadImages:[originalImageArray mutableCopy] completion:^(id result) {
        
        [self setupImagesScrollView];
        
    }];
    
    // initialize with videos
    
    originalVideoArray = self.listingDetail[@"videos"];
    [self downloadVideos:[originalVideoArray mutableCopy] completion:^(id result) {
        
        [self setupVideosScrollView];
        
    }];
    
    // initialize with tags
    NSArray *tagDetails = self.listingDetail[@"tag"];
    originalTagArray = tagDetails;
    
    NSMutableArray *tagNames = [NSMutableArray array];
    for (NSDictionary *tag in tagDetails) {
        [tagNames addObject:tag[@"name"]];
    }
    self.tagsControl.tags = tagNames;
    [self.tagsControl reloadTagSubviews];
}

- (void)getPricingLimits {
    [self.backend getPricingLimits:^(NSDictionary *result) {
        if (result && result[@"response"] && ![result[@"response"] isKindOfClass:[NSNull class]]) {
            if (result[@"response"][@"base_max_price"] && result[@"response"][@"base_min_price"] && result[@"response"][@"addon_max_price"] && result[@"response"][@"addon_min_price"]){
                self.base_max_price = [result[@"response"][@"base_max_price"] doubleValue];
                self.base_min_price = [result[@"response"][@"base_min_price"] doubleValue];
                self.addon_max_price = [result[@"response"][@"addon_max_price"] doubleValue];
                self.addon_min_price = [result[@"response"][@"addon_min_price"] doubleValue];
            }
        }
    }];
}

- (void)doneClicked:(UIBarButtonItem*)button {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.localSearchQueries removeAllObjects];
    [self.pastSearchResults removeAllObjects];
    [self.pastSearchWords removeAllObjects];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationUpdated) name:kNotificationDidLocationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recycleBinButtonTapped:) name:kNotificationDidTapRecycleBinButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPhotoButtonClicked:) name:kNotificationDidTapAddPhotoButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addVideoButtonClicked:) name:kNotificationDidTapAddVideoButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listingImageViewTapped:) name:kNotificationDidTapListingImageView object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Observer
- (void)userLocationUpdated {
    selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([[User currentUser].latitude floatValue], [[User currentUser].longitude floatValue]);
}

- (void) recycleBinButtonTapped:(NSNotification *)notif {
    NSInteger index = [notif.object[@"index"] integerValue];
    ListingMediaType type = [notif.object[@"type"] integerValue];
    
    if (type == ListingMediaTypePhoto) {
        [self.listingImages removeObjectAtIndex:index];
        [self setupImagesScrollView];
    } else {
        [self.listingVideos removeObjectAtIndex:index];
        [self setupVideosScrollView];
    }
}
- (void)addPhotoButtonClicked:(id)sender {
//    self.picker = [[GKImagePicker alloc] init];
//    self.picker.delegate = self;
//    self.picker.cropper.cropSize = CGSizeMake(320.,200.);   // (Optional) Default: CGSizeMake(320., 320.)
//    self.picker.cropper.rescaleImage = YES;                // (Optional) Default: YES
//    self.picker.cropper.rescaleFactor = 2.0;               // (Optional) Default: 1.0
//    self.picker.cropper.dismissAnimated = YES;              // (Optional) Default: YES
//    self.picker.cropper.overlayColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7];  // (Optional) Default: [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7]
//    self.picker.cropper.innerBorderColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.7];   // (Optional) Default: [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7]
//    [self.picker presentPicker];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Where do you want to get photo?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Gallery", nil];
    actionSheet.delegate = self;
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];

}
- (void) addVideoButtonClicked:(NSNotification *)notif {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Where do you want to get video?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Gallery", nil];
    actionSheet.delegate = self;
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
}
- (void) listingImageViewTapped:(NSNotification *)notif {
    NSInteger index = [notif.object[@"index"] integerValue];
    ListingMediaType type = [notif.object[@"type"] integerValue];
    
    if (type == ListingMediaTypePhoto) {
        for (ListingImageView *listingImageView in listingImageViewArray) {
            if (listingImageView.index != index) {
                listingImageView.selected = NO;
            }
        }
    } else {
        for (ListingImageView *listingImageView in listingThumbnailViewArray) {
            if (listingImageView.index != index) {
                listingImageView.selected = NO;
            }
        }
    }
    
}
#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;

    if (actionSheet.tag == 101) {
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        picker.allowsEditing = YES;
    } else {
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        picker.allowsEditing = NO;
    }
    
    switch (buttonIndex) {
        case 0:
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    if (videoURL) {
        NSString *videoWebURL = [self uploadVideo:videoURL];

        UIImage *thumbnailImage = [self thumbnailImageFromURL:videoURL];
        NSString *thumbnailURL = [self uploadImage:thumbnailImage Folder:@"Preview"];
        [self.listingVideos addObject:@{@"uploaded": @NO, @"url":videoWebURL, @"videoURL":videoURL, @"image":thumbnailImage, @"preview":thumbnailURL}];
        [self setupVideosScrollView];
    } else {
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self.listingImages addObject:@{@"uploaded": @NO, @"image":image}];
            [self setupImagesScrollView];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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

- (IBAction)menuButtonTapped:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}
- (IBAction)backButtonTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)submitButtonTapped:(id)sender {
    
    NSString* title = self.titleTextField.text;

    
    NSString* foundAddonDescription = @"";
    NSMutableArray *addonArray = [NSMutableArray array];
    for (NSMutableDictionary *addon in addOns) {
        if (![addon[@"description"] isEqualToString:@""]) {
            [addonArray addObject:addon];
            if ([[NSString stringWithFormat:@"%@",addon[@"price"]] isEqualToString:@""]) {
                foundAddonDescription = addon[@"description"];
                break;
            }
        }
    }
    if (selectedLocation.locationCoordinates.latitude == 0 && selectedLocation.locationCoordinates.longitude == 0) {
        
        [self showMessage:@"Creating a listing requires location services. Please enable it on your phone settings for Dubb"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    if (![foundAddonDescription isEqualToString:@""]) {
        [self showMessage:[NSString stringWithFormat:@"Please enter your price for addon service - %@", foundAddonDescription]];
        return;
    }
    
    if (title.length <= 0) {
        [self showMessage:@"Please enter the title for this listing"];
        return;
    }
    if (self.categoryTextField.selectedRow == -1 || self.subCategoryTextField.selectedRow == -1) {
        [self showMessage:@"Please select one category."];
        return;
    }
    
    if (self.tagsControl.tags.count < 3) {
        
        [self showMessage:@"Please add minimum 3 tags."];
        return;
    }
    
    if (self.baseServiceDescriptionTextView.text.length <= 0) {
        [self showMessage:@"Please describe your base service."];
        return;
    }
    
    if ([self.baseServicePriceTextField.text isEqualToString:@""]) {
        [self showMessage:@"Please enter your price for base service."];
        return;
    }
    
    if (self.listingImages.count == 0) {
        [self showMessage:@"Please select at least one image."];
        return;
    }
    
    double base_price = [self.baseServicePriceTextField.text doubleValue];

    if (base_price > self.base_max_price) {
        [self showMessage:[NSString stringWithFormat:@"Maximum base service price is $%.f.", self.base_max_price]];
        return;
    }

    if (base_price < self.base_min_price) {
        [self showMessage:[NSString stringWithFormat:@"Minimum base service price is $%.f.", self.base_min_price]];
        return;
    }

    for (NSDictionary *addon in addonArray) {
        double addon_price = [addon[@"price"] doubleValue];

        if (addon_price > self.addon_max_price) {
            [self showMessage:[NSString stringWithFormat:@"Maximum addon price is $%.f.", self.addon_max_price]];
            return;
        }

        if (addon_price < self.addon_min_price) {
            [self showMessage:[NSString stringWithFormat:@"Minimum addon price is $%.f.", self.addon_min_price]];
            return;
        }
    }
    
    NSMutableArray *imageURLs = [self uploadImages];
    NSArray *tagsArray = self.tagsControl.tags;
    radius = self.radiusTextField.text;
    
    
    
    NSString *apiPath = [NSString stringWithFormat:@"%@", @"listing"];
    [self showProgress:@"Wait for a moment"];
    
    NSMutableDictionary *params;
    
    if (self.listingDetail) {
        
        [addonArray insertObject:@{@"id":baseServiceID, @"description":self.baseServiceDescriptionTextView.text, @"price":self.baseServicePriceTextField.text} atIndex:0];
        for (NSDictionary *originalAddon in originalAddonArray) {
            BOOL found = NO;
            for (NSDictionary *addon in addonArray) {
                if ([addon objectForKey:@"id"] && [addon[@"id"] isEqualToString:originalAddon[@"id"]]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [addonArray addObject:@{@"id":originalAddon[@"id"], @"delete":@"true"}];
            }
        }
        
        NSMutableArray *tagArrayForUpdate = [NSMutableArray array];
        for (NSDictionary *originalTag in originalTagArray) {
            BOOL found = NO;
            for (NSString *tag in tagsArray) {
                if ([tag isEqualToString:originalTag[@"name"]]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [tagArrayForUpdate addObject:@{@"id":originalTag[@"id"], @"delete":@"true"}];
            }
        }
        
        for (NSString *tag in tagsArray) {
            BOOL found = NO;
            for (NSDictionary *originalTag in originalTagArray) {
                if ([tag isEqualToString:originalTag[@"name"]]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [tagArrayForUpdate addObject:@{@"name":tag}];
            }
        }
        
        NSMutableArray *assetArrayForUpdate = [NSMutableArray array];
        for (NSDictionary *originalAsset in originalImageArray) {
            BOOL found = NO;
            for (NSDictionary *listingImage in self.listingImages) {
                if ([listingImage[@"id"] isEqualToString:originalAsset[@"id"]]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [assetArrayForUpdate addObject:@{@"id":originalAsset[@"id"], @"delete":@"true"}];
            }
        }
        
        for (NSString *newImageURL in imageURLs) {
            
            [assetArrayForUpdate addObject:@{@"url":newImageURL, @"type":@"image"}];
            
        }
        
        
        for (NSDictionary *originalAsset in originalVideoArray) {
            BOOL found = NO;
            for (NSDictionary *listingVideo in self.listingVideos) {
                if ([listingVideo[@"id"] isEqualToString:originalAsset[@"id"]]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [assetArrayForUpdate addObject:@{@"id":originalAsset[@"id"], @"delete":@"true"}];
            }
        }
        for (NSDictionary *newVideoObject in self.listingVideos) {
            if ([newVideoObject[@"uploaded"] isEqualToNumber:@NO])
                [assetArrayForUpdate addObject:@{@"url":newVideoObject[@"url"], @"preview":newVideoObject[@"preview"], @"type":@"video"}];
            
        }
        
        
        
        
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"name":[NSString stringWithFormat:@"%@", self.titleTextField.text],
                   @"instructions":self.fulfillmentInfoTextView.text,
                   @"description":self.baseServiceDescriptionTextView.text,
                   @"category_id":categories[self.categoryTextField.selectedRow][@"id"],
                   @"category_edge_id":subCategories[self.subCategoryTextField.selectedRow][@"category_edge_id"],
                   @"user_id":[User currentUser].userID,
                   @"lat":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.latitude],
                   @"longitude":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.longitude],
                   @"radius_mi":radius,
                   @"addon":addonArray,
                   @"tag":tagArrayForUpdate,
                   @"asset":assetArrayForUpdate
                   }];
        [self.backend updateListing:self.listingDetail[@"id"] Parameters:params CompletionHandler:^(NSDictionary *result) {
            [self hideProgress];
            [self showMessage:@"Successfully updated the listing."];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    } else {
        
        [addonArray insertObject:@{@"description":self.baseServiceDescriptionTextView.text, @"price":self.baseServicePriceTextField.text} atIndex:0];
        NSMutableArray *imagesWithoutMainImage = [imageURLs mutableCopy];
        NSMutableArray *videosWithoutMainVideo = [NSMutableArray array];
        for (NSDictionary *videoObject in self.listingVideos) {
            [videosWithoutMainVideo addObject:@{@"url":videoObject[@"url"], @"preview":videoObject[@"preview"]}];
        }
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"name":[NSString stringWithFormat:@"%@", self.titleTextField.text],
                                                                 @"instructions":self.fulfillmentInfoTextView.text,
                                                                 @"description":self.baseServiceDescriptionTextView.text,
                                                                 @"category_id":categories[self.categoryTextField.selectedRow][@"id"],
                                                                 @"category_edge_id":subCategories[self.subCategoryTextField.selectedRow][@"category_edge_id"],
                                                                 @"user_id":[User currentUser].userID,
                                                                 @"lat":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.latitude],
                                                                 @"longitude":[NSString stringWithFormat:@"%f", selectedLocation.locationCoordinates.longitude],
                                                                 @"radius_mi":radius,
                                                                 @"addon":addonArray,
                                                                 @"main_image":imageURLs[0],
                                                                 @"tags":tagsArray
                                                                 }];
        if (imagesWithoutMainImage.count > 1) {
            [imagesWithoutMainImage removeObjectAtIndex:0];
            params[@"images"] = imagesWithoutMainImage;
        }
        if (videosWithoutMainVideo.count > 0) {
            params[@"main_video"] = videosWithoutMainVideo[0][@"url"];
            params[@"main_video_preview"] = videosWithoutMainVideo[0][@"preview"];
            
            if (videosWithoutMainVideo.count > 1) {
                [videosWithoutMainVideo removeObjectAtIndex:0];
                params[@"videos"] = videosWithoutMainVideo;
            }
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
   
}

- (void)setupImagesScrollView
{
    self.imagesScrollView.delegate = self;
    [self.imagesScrollView setCanCancelContentTouches:NO];
    self.imagesScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.imagesScrollView.clipsToBounds = NO;
    self.imagesScrollView.scrollEnabled = YES;
    
    for(UIView *subview in [self.imagesScrollView subviews]) {
        [subview removeFromSuperview];
    }
    listingImageViewArray = [NSMutableArray array];
    NSInteger tot=0;
    
    CGFloat cx = 0;
    
    ListingImageView *addPhotoView = [[[NSBundle mainBundle] loadNibNamed:@"ListingImageView" owner:nil options:nil] firstObject];
    CGRect rect = addPhotoView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    addPhotoView.frame = rect;
    [addPhotoView showAddPhotoView];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [view1 addSubview:addPhotoView];
    [self.imagesScrollView addSubview:view1];

    cx += addPhotoView.frame.size.width + 4;

    for (NSDictionary *listingImage in self.listingImages) {
        UIImage *image = listingImage[@"image"];
        ListingImageView *listingImageView = [[[NSBundle mainBundle] loadNibNamed:@"ListingImageView" owner:nil options:nil] firstObject];
        CGRect rect = listingImageView.frame;
        rect.origin.x = cx;
        rect.origin.y = 0;
        listingImageView.imageView.image = image;
        listingImageView.type = ListingMediaTypePhoto;
        listingImageView.index = tot;
        [listingImageViewArray addObject:listingImageView];
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        [view2 addSubview:listingImageView];
        view2.frame = rect;
        [self.imagesScrollView addSubview:view2];
        cx += listingImageView.frame.size.width + 4;
        tot++;
    }
    
    [self.imagesScrollView setContentSize:CGSizeMake(cx, [self.imagesScrollView bounds].size.height)];
    self.imagesCountLabel.text = [NSString stringWithFormat:@"%ld IMAGES", self.listingImages.count];
}

- (void)setupVideosScrollView
{
    self.videosScrollView.delegate = self;
    [self.videosScrollView setCanCancelContentTouches:NO];
    self.videosScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.videosScrollView.clipsToBounds = NO;
    self.videosScrollView.scrollEnabled = YES;
    
    for(UIView *subview in [self.videosScrollView subviews]) {
        [subview removeFromSuperview];
    }
    listingThumbnailViewArray = [NSMutableArray array];
    NSInteger tot=0;
    
    CGFloat cx = 0;
    
    ListingImageView *addVideoView = [[[NSBundle mainBundle] loadNibNamed:@"ListingImageView" owner:nil options:nil] firstObject];
    CGRect rect = addVideoView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    addVideoView.frame = rect;
    [addVideoView showAddVideoView];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [view1 addSubview:addVideoView];
    [self.videosScrollView addSubview:view1];
    
    cx += addVideoView.frame.size.width + 4;
    
    for (NSDictionary *listingImage in self.listingVideos) {
        UIImage *image = listingImage[@"image"];
        ListingImageView *listingImageView = [[[NSBundle mainBundle] loadNibNamed:@"ListingImageView" owner:nil options:nil] firstObject];
        CGRect rect = listingImageView.frame;
        rect.origin.x = cx;
        rect.origin.y = 0;
        listingImageView.imageView.image = image;
        listingImageView.type = ListingMediaTypeVideo;
        listingImageView.index = tot;
        [listingThumbnailViewArray addObject:listingImageView];
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        [view2 addSubview:listingImageView];
        view2.frame = rect;
        [self.videosScrollView addSubview:view2];
        cx += listingImageView.frame.size.width + 4;
        tot++;
    }
    
    [self.videosScrollView setContentSize:CGSizeMake(cx, [self.videosScrollView bounds].size.height)];
    self.videosCountLabel.text = [NSString stringWithFormat:@"%ld VIDEOS", self.listingVideos.count];
}

- (NSMutableArray *) uploadImages{
    
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    for (NSDictionary *listingImage in self.listingImages) {
        if ([listingImage[@"uploaded"] boolValue]) {
            continue;
        }
        UIImage *image = listingImage[@"image"];
        [imageURLs addObject:[self uploadImage:image]];
//        NSData *data = UIImageJPEGRepresentation(image, 0.7);
//        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
//        NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
//        
//        [fileManager createFileAtPath:tempFilePath contents:data attributes:nil];
//        [imageURLs addObject:[NSString stringWithFormat:@"http://asset.dubb.com/completed/%@", fileName]];
//        [self uploadFileWithFileName:fileName SourcePath:tempFilePath FileURL:nil];
    }
    
    return imageURLs;
}

- (NSString *) uploadVideo:(NSURL *)videoURL{
    [self showProgress:@"Uploading the video..."];
    NSString *fileName = [NSString stringWithFormat:@"Video/%@", [[NSUUID UUID] UUIDString]];
    NSString *videoURLString = [NSString stringWithFormat:@"cloudinary://%@", fileName];
    [self uploadFileWithFileName:fileName SourcePath:nil FileURL:videoURL Type:@"video"];
    [self hideProgress];
    return videoURLString;
}

- (NSString *) uploadImage:(UIImage *)image {
    return [self uploadImage:image Folder:@"Listing"];
}

- (NSString *) uploadImage:(UIImage *)image Folder:(NSString*)folder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *fileName = [NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]];
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    fileName = [NSString stringWithFormat:@"%@/%@", folder, fileName];

    [fileManager createFileAtPath:tempFilePath contents:data attributes:nil];
    NSString *imageURLString = [NSString stringWithFormat:@"cloudinary://%@", fileName];
    [self uploadFileWithFileName:fileName SourcePath:tempFilePath FileURL:nil];
    return imageURLString;
}

- (NSString *) uploadVideo1:(NSURL *)videoURL{
    
    [self showProgress:@"Uploading the video..."];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", [[NSUUID UUID] UUIDString], videoURL.pathExtension];
    NSString *videoURLString = [NSString stringWithFormat:@"http://asset.dubb.com/completed/%@", fileName];
    [self uploadFileWithFileName:fileName SourcePath:nil FileURL:videoURL];
    return videoURLString;
}

- (NSString *) uploadImage1:(UIImage *)image{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [fileManager createFileAtPath:tempFilePath contents:data attributes:nil];
    NSString *imageURLString = [NSString stringWithFormat:@"http://asset.dubb.com/completed/%@", fileName];
    [self uploadFileWithFileName:fileName SourcePath:tempFilePath FileURL:nil];
    return imageURLString;
}

- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath FileURL:(NSURL *)fileURL {
    [self uploadFileWithFileName:fileName SourcePath:sourcePath FileURL:fileURL Type:nil];
}

- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath FileURL:(NSURL *)fileURL Type:(NSString*) type {
    NSURL *fullPath;
    if (sourcePath) {
        fullPath = [NSURL fileURLWithPath:sourcePath
                              isDirectory:NO];
    } else {
        fullPath = fileURL;
    }

    [self.backend getUploadSignature:fileName CompletionHandler: ^(NSDictionary *result) {
        if(result) {
            CLUploader* mobileUploader = [[CLUploader alloc] init:self.cloudinary delegate:self];
            NSMutableDictionary* options = result[@"response"];
            [options setValue:@YES forKey:@"sync"];

            if (type) {
                [options setValue:type forKey:@"resource_type"];
            }

            [mobileUploader upload:fullPath.path options:options];
        }
    }];
}

- (void)uploadFileWithFileName1:(NSString *)fileName SourcePath:(NSString *)sourcePath FileURL:(NSURL *)fileURL {
    
    NSURL *fullPath;
    if (sourcePath) {
        fullPath = [NSURL fileURLWithPath:sourcePath
                              isDirectory:NO];
    } else {
        fullPath = fileURL;
    }
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"listing-image-uploads";
    uploadRequest.key = [NSString stringWithFormat:@"completed/%@", fileName];
    uploadRequest.body = fullPath;
    uploadRequest.contentType = @"movie/mov";
    
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
        
        [self hideProgress];
        return nil;
    }];
    
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView == self.locationSearchTableView) {
        switch (section) {
            case TableViewSectionCurrentLocation:
                return 1;
                break;
            case TableViewSectionMain:
                return self.localSearchQueries.count;
                break;
        }
        
        return 0;
    } else {
        return addOns.count;
    }
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (tableView == self.locationSearchTableView) {
        switch (indexPath.section) {
            case TableViewSectionCurrentLocation: {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentLocationCell" forIndexPath:indexPath];
                
            }break;
            case TableViewSectionMain: {
                cell =  [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
                NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
                if ([searchResult isKindOfClass:[NSDictionary class]]) {
                    
                    @try{
                        cell.textLabel.text = [searchResult[@"terms"] objectAtIndex:0][@"value"];
                        cell.detailTextLabel.text = searchResult[@"description"];
                        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0];

                    }@catch(NSException *e){
                        NSLog(@"%@", e.description);
                    }
                                    }
                
            }break;
            default:
                break;
        }

    } else{
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddOnCell"];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddOnCell"];
        
        UILabel *addonNumberLabel = (UILabel *)[cell viewWithTag:100];
        UIView *descriptionContainerView = [cell viewWithTag:103];
        UITextField *descriptionTextField = (UITextField *)[descriptionContainerView viewWithTag:101];
        UITextField *priceTextField = (UITextField *)[[cell viewWithTag:104] viewWithTag:102];
        
        UILabel *dollarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, priceTextField.frame.size.height)];
        dollarLabel.text = @"$";
        dollarLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        priceTextField.leftView = dollarLabel;
        priceTextField.leftViewMode = UITextFieldViewModeAlways;
        
        addonNumberLabel.text = [NSString stringWithFormat:@"ADD-ON %ld", indexPath.row + 1];
        
        NSMutableDictionary *addOn = addOns[indexPath.row];
        if (![addOn[@"price"] isEqualToString:@""]) {
            addOn[@"price"] = [NSString stringWithFormat:@"%ld", [addOn[@"price"] integerValue]];
        }

        [priceTextField setText:[NSString stringWithFormat:@"%@", addOn[@"price"]]];
        [descriptionTextField setText:addOn[@"description"]];

        descriptionTextField.inputAccessoryView = [self kudosMessageToolbar];
        
        cell.contentView.tag = indexPath.row;
        
        priceTextField.delegate = self;
        descriptionTextField.delegate = self;
        

    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (addOns.count > 1) {
        return YES;
    }
    
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [tableView beginUpdates];
        [addOns removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [tableView reloadData];
        

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (tableView == self.locationSearchTableView) {
        return TableViewSectionCount;
    } else {
        return 1;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        return;
    }
    
    switch (indexPath.section) {
        case TableViewSectionMain: {
            //this is where it broke
            NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
            
            if ([searchResult isKindOfClass:[NSDictionary class]]) {
                NSString *placeID = [searchResult objectForKey:@"place_id"];
                [self.searchTextField resignFirstResponder];
                [self retrieveJSONDetailsAbout:placeID withCompletion:^(NSArray *place) {
                    
                    if ([place isKindOfClass:[NSDictionary class]]) {
                        selectedLocation.name = [place valueForKey:@"name"];
                        selectedLocation.address = [place valueForKey:@"formatted_address"];
                        NSString *latitude = [NSString stringWithFormat:@"%@,",[place valueForKey:@"geometry"][@"location"][@"lat"]];
                        NSString *longitude = [NSString stringWithFormat:@"%@",[place valueForKey:@"geometry"][@"location"][@"lng"]];
                        
                        selectedLocation.locationCoordinates = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                        NSLog(@"Location Info: %@",selectedLocation);
                        
                        [self.searchTextField setText:[NSString stringWithFormat:@"%@",selectedLocation.address]];
                    }
                    
                    
                }];

            }
            
        }break;
            
        case TableViewSectionCurrentLocation: {
            
            selectedLocation.name = @"Current Location";
            selectedLocation.address = [NSString stringWithFormat:@"%@, %@", [User currentUser].city, [User currentUser].state];
            selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([[User currentUser].latitude floatValue], [[User currentUser].longitude floatValue]);
            
            [self.searchTextField setText:@"Current Location"];
        }break;
        default:
            break;
    }
    
    [self.locationSearchTableView deselectRowAtIndexPath:indexPath animated:NO];
    self.locationSearchTableView.hidden = YES;
}


#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.locationSearchTableView) {
        return 44;
    } else{
        return 128;
    }
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self.availableCharacterNumberLabel setText:[NSString stringWithFormat:@"%ld", MAX_CHARACTER_NUMBER_BASE - [textView.text length]]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > MAX_CHARACTER_NUMBER_BASE) ? NO : YES;
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    NSString *replacedText = [textField.text stringByReplacingCharactersInRange:range withString:text];
    if (textField == self.searchTextField) {
        self.substring = [NSString stringWithString:self.searchTextField.text];
        self.substring = [self.substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        self.substring = [self.substring stringByReplacingCharactersInRange:range withString:text];
        
        if ([self.substring hasPrefix:@"+"] && self.substring.length >1) {
            self.substring  = [self.substring substringFromIndex:1];
            NSLog(@"This string: %@ had a space at the begining.",self.substring);
        }
        
        if ([self.searchTextField.text isEqualToString:@"Current Location"]) {
            self.searchTextField.text = text;
            return NO;
        }
    } else if (textField.superview.tag == 103 || textField.superview.tag == 104) {
        
        NSLog(@"%ld", MAX_CHARACTER_NUMBER_ADDON - [replacedText length]);
        [self.availableCharacterNumberLabelForAddon setText:[NSString stringWithFormat:@"%ld", MAX_CHARACTER_NUMBER_ADDON - [replacedText length]]];
        [self textFieldValueDidChange:textField WithText:replacedText];
    }
    
    NSUInteger newLength = [textField.text length] + [text length] - range.length;
    if (newLength > MAX_CHARACTER_NUMBER_ADDON)
        return NO;
    
    if (textField.superview.tag == 104 && replacedText.length == 5) {
        return NO;
    } else {
        return YES;
    }

    
}

// hide keyboard when the background is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)runScript{
    
    [self.autoCompleteTimer invalidate];
    self.autoCompleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.65f
                                                              target:self
                                                            selector:@selector(searchAutocompleteLocationsWithSubstring:)
                                                            userInfo:nil
                                                             repeats:NO];
}

#pragma mark - UITextField Delegate
- (IBAction)textFieldDidChange:(id)sender {
    
    NSString *searchWordProtection = [self.searchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Length: %lu",(unsigned long)searchWordProtection.length);
    
    if (searchWordProtection.length != 0) {
        
        [self runScript];
        
    } else {
        NSLog(@"The searcTextField is empty.");
    }
    
}
- (IBAction)textFieldEditingDidBegin:(id)sender {
    if (sender == self.radiusTextField) {
        self.locationSearchTableView.hidden = YES;
    } else {
        CGPoint newContentOffset = CGPointMake(0, [self.tableView contentSize].height -  self.tableView.bounds.size.height);
        [self.tableView setContentOffset:newContentOffset animated:YES];
        self.locationSearchTableView.hidden = NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.availableCharacterNumberLabelForAddon) {
        self.availableCharacterNumberLabelForAddon.text = [NSString stringWithFormat:@"%ld", MAX_CHARACTER_NUMBER_ADDON - [textField.text length]];
    }
}



- (void)searchAutocompleteLocationsWithSubstring:(NSString *)substring
{
    [self.localSearchQueries removeAllObjects];
    [self.locationSearchTableView reloadData];
    
    if (![self.pastSearchWords containsObject:self.substring]) {
        [self.pastSearchWords addObject:self.substring];
        NSLog(@"Search: %lu",(unsigned long)self.pastSearchResults.count);
        [self retrieveGooglePlaceInformation:self.substring withCompletion:^(NSArray * results) {
            [self.localSearchQueries addObjectsFromArray:results];
            NSDictionary *searchResult = @{@"keyword":self.substring,@"results":results};
            [self.pastSearchResults addObject:searchResult];
            [self.locationSearchTableView reloadData ];
            
        }];
        
    }else {
        
        for (NSDictionary *pastResult in self.pastSearchResults) {
            if([[pastResult objectForKey:@"keyword"] isEqualToString:self.substring]){
                [self.localSearchQueries addObjectsFromArray:[pastResult objectForKey:@"results"]];
                [self.locationSearchTableView reloadData];
            }
        }
    }
}


#pragma mark - Google API Requests


-(void)retrieveGooglePlaceInformation:(NSString *)searchWord withCompletion:(void (^)(NSArray *))complete{
    NSString *searchWordProtection = [searchWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (searchWordProtection.length != 0) {
        
        CLLocation *userLocation = self.locationManager.location;
        NSString *currentLatitude = @(userLocation.coordinate.latitude).stringValue;
        NSString *currentLongitude = @(userLocation.coordinate.longitude).stringValue;
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=500&language=en&key=%@",searchWord,currentLatitude,currentLongitude,apiKey];
        NSLog(@"AutoComplete URL: %@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *results = [jSONresult valueForKey:@"predictions"];
            
            if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
                if (!error){
                    NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                    NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                    complete(@[@"API Error", newError]);
                    return;
                }
                complete(@[@"Actual Error", error]);
                return;
            }else{
                complete(results);
            }
        }];
        
        [task resume];
    }
    
}

-(void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSArray *))complete {
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",place,apiKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"result"];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                complete(@[@"API Error", newError]);
                return;
            }
            complete(@[@"Actual Error", error]);
            return;
        }else{
            complete(results);
        }
    }];
    
    [task resume];
}

typedef void (^completion_t)(id result);
- (void) downloadImages:(NSMutableArray*)images
          completion:(completion_t)completionHandler {
    
    if ([images count] == 0) {
        if (completionHandler) {
            // Signal completion to the call-site. Use an appropriate result,
            // instead of @"finished" possibly pass an array of URLs and NSErrors
            // generated below  in "handle URL or error".
            completionHandler(@"finished");
        }
        return;
    }
    
    NSDictionary* imageInfo = [images firstObject];
    [images removeObjectAtIndex:0];

    NSString* imageUrlString;
    NSURL* imageUrl = [NSURL URLWithString:imageInfo[@"url"]];

    if ([[imageUrl scheme] isEqualToString:@"cloudinary"]) {
        imageUrlString = [self.cloudinary url:[imageUrl host]];
    } else {
        imageUrlString = imageInfo[@"url"];
    }

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:imageUrlString]
                          options:0
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                [self.listingImages addObject:@{@"id":imageInfo[@"id"], @"image":image, @"uploaded":@YES}];
                            }
                            NSLog(@"remaining count : %ld", images.count);
                            [self downloadImages:images completion:completionHandler];
                        }];
    
}

- (void) downloadVideos:(NSMutableArray*)videos
             completion:(completion_t)completionHandler {
    
    if ([videos count] == 0) {
        if (completionHandler) {
            // Signal completion to the call-site. Use an appropriate result,
            // instead of @"finished" possibly pass an array of URLs and NSErrors
            // generated below  in "handle URL or error".
            completionHandler(@"finished");
        }
        return;
    }
    
    NSDictionary* videoInfo = [videos firstObject];
    [videos removeObjectAtIndex:0];

    NSString* imageUrlString;
    NSURL* imageUrl = [NSURL URLWithString:videoInfo[@"preview"]];

    if ([[imageUrl scheme] isEqualToString:@"cloudinary"]) {
        imageUrlString = [self.cloudinary url:[imageUrl host]];
    } else {
        imageUrlString = videoInfo[@"preview"];
    }


    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:imageUrlString]
                          options:0
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                [self.listingVideos addObject:@{@"id":videoInfo[@"id"], @"image":image, @"uploaded":@YES}];
                            }
                            NSLog(@"remaining count : %ld", videos.count);
                            [self downloadVideos:videos completion:completionHandler];
                        }];
    
}


- (void)textFieldValueDidChange:(UITextField *)sender WithText:(NSString *)text{
    
//    if (sender.tag >= addOns.count ) {
//        return;
//    }
    NSInteger currentIndex = sender.superview.superview.tag;
    if (sender.superview.tag == 103) {
        addOns[currentIndex][@"description"] = text;
    } else if (sender.superview.tag == 104) {
        addOns[currentIndex][@"price"] = text;
    }
    
    if (currentIndex == addOns.count - 1) {
        [self.tableView beginUpdates];
        [addOns addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"description":@"", @"price":@""}]];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:addOns.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

#pragma mark - Custom Helper Method returning toolbar for Addon Description TextFields

- (UIToolbar *)kudosMessageToolbar {
    
    
    
    if (!self.availableCharacterNumberLabelForAddon && !addonToolbar) {
        addonToolbar = [[UIToolbar alloc] init];
        [addonToolbar sizeToFit];
        self.availableCharacterNumberLabelForAddon = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
        [self.availableCharacterNumberLabelForAddon setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [self.availableCharacterNumberLabelForAddon setBackgroundColor:[UIColor clearColor]];
        [self.availableCharacterNumberLabelForAddon setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
        
        [self.availableCharacterNumberLabelForAddon setTextAlignment:NSTextAlignmentCenter];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        
        UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:self.availableCharacterNumberLabelForAddon];
        
        
        [addonToolbar setItems:@[spacer, title, spacer] animated:YES];
    }
    
    
    [self.availableCharacterNumberLabelForAddon setText:@""];
    
    
    return addonToolbar;
}

#pragma mark - Custom Helpers

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL: videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime requestedTime = CMTimeMake(1, 60);     // To create thumbnail image
    CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
    NSLog(@"err = %@, imageRef = %@", err, imgRef);
    
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);    // MUST release explicitly to avoid memory leak
    
    return thumbnailImage;
}

#pragma mark - GKImagePicker delegate methods

- (void)imagePickerDidFinish:(GKImagePicker *)imagePicker withImage:(UIImage *)image {
    UIImage *chosenImage = image;
    [self.listingImages addObject:@{@"uploaded": @NO, @"image":chosenImage}];
    [self setupImagesScrollView];
}

#pragma mark - Cloudinary delegate methods

- (void)uploaderSuccess:(NSString*)result context:(id)context {

}

- (void)uploaderError:(NSString*)result code:(NSInteger)code context:(id)context {

}

- (void)uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"displayCreateListingConfirmationSegue"]) {
        DubbCreateListingConfirmationViewController *viewController = segue.destinationViewController;
        
        NSString *string = self.titleTextField.text;
        viewController.listingTitle = string;
        viewController.listingLocation = selectedLocation;
        viewController.mainImage = self.listingImages[0][@"image"];
        viewController.categoryDescription = [NSString stringWithFormat:@"%@ / %@", self.categoryTextField.text, self.subCategoryTextField.text];
        viewController.baseServicePrice = [self.baseServicePriceTextField.text integerValue];

    }
}

@end
