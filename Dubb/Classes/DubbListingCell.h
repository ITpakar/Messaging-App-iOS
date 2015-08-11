//
//  DubbListingCell.h
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DubbListingCell;

@protocol DubbListingCellDelegate

-(void) onPay :(NSDictionary*) listing Location:(NSString*) location;

@end

@interface DubbListingCell : UITableViewCell

-(void) initWithListingInfo:(NSDictionary*)listing;
@property (nonatomic, strong) NSDictionary* listing;
@property id delegate;

@end
