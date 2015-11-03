//
//  DubbCreateListingTableViewController.h
//  Dubb
//
//  Created by andikabijaya on 3/16/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerHeader.h"
#import "KASlideShow.h"
#import "DubbServiceDescriptionViewController.h"
#import "DubbServiceDescriptionWithPriceViewController.h"
#import "BaseViewController.h"
#import "SelectedLocation.h"
#import "Cloudinary/Cloudinary.h"

@interface DubbCreateListingTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, CLUploaderDelegate>

@property (nonatomic, strong) NSMutableArray *listingImages;
@property (nonatomic, strong) NSMutableArray *listingVideos;
@property (nonatomic, strong) NSDictionary *listingDetail;
@property NSMutableArray *pastSearchResults;
@property NSMutableArray *pastSearchWords;
@property NSMutableArray *localSearchQueries;
@property NSTimer *autoCompleteTimer;
@property NSString *substring;
@property CLLocationManager *locationManager;
@property NSString *radius;
@property NSString *titleString;
@property double base_max_price;
@property double base_min_price;
@property double addon_max_price;
@property double addon_min_price;
@end
