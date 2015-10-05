//
//  DubbListingCell.h
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class DubbListingCell;

@protocol DubbListingCellDelegate

-(void) onPay :(NSDictionary*) listing Location:(NSString*) location;

@end

@interface DubbListingCell : UITableViewCell

-(void) initWithListingInfo:(NSDictionary*)listing;
-(void) setDownloadProgress:(CGFloat)progress;

@property CGRect listingImageViewFrame;
@property (nonatomic, strong) BaseViewController* baseVC;
@property (nonatomic, strong) NSDictionary* listing;
@property id delegate;

@end
