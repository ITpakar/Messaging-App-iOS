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

@interface DubbCreateListingTableViewController : BaseViewController <ELCImagePickerControllerDelegate, KASlideShowDelegate, UITableViewDataSource, UITableViewDelegate, DubbServiceDescriptionViewControllerDelegate, DubbServiceDescriptionWithPriceViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *chosenImages;
@property (nonatomic, strong) NSDictionary *listingDetail;
- (void) completedWithDescription:(NSString*)description;
- (void) completedWithDescription:(NSString*)description WithPrice:(NSString *)price;
@end
