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

@interface DubbCreateListingTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *listingImages;
@property (nonatomic, strong) NSDictionary *listingDetail;
@property NSMutableArray *pastSearchResults;
@property NSMutableArray *pastSearchWords;
@property NSMutableArray *localSearchQueries;
@property NSTimer *autoCompleteTimer;
@property NSString *substring;
@property CLLocationManager *locationManager;
@property NSString *radius;
@property NSString *titleString;
@end
