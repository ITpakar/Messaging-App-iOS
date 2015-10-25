//
//  DubbCreateListingConfirmationViewController.h
//  Dubb
//
//  Created by andikabijaya on 4/25/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SelectedLocation.h"
#import "BaseViewController.h"
@interface DubbCreateListingConfirmationViewController : BaseViewController 


@property (strong, nonatomic) NSString         *listingTitle;
@property (nonatomic)         NSInteger        baseServicePrice;
@property (strong, nonatomic) SelectedLocation *listingLocation;
@property (strong, nonatomic) UIImage          *mainImage;
@property (strong, nonatomic) NSString         *mainImageURL;
@property (strong, nonatomic) NSString         *categoryDescription;
@property (strong, nonatomic) NSString         *slugUrlString;

@end
