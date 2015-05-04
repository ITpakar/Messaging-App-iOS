//
//  DubbListingCell.h
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbListingCell : UITableViewCell

@property (nonatomic, strong) NSDictionary* listing;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier listingInfo:(NSDictionary*)listing;

@end
