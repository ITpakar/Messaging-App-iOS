//
//  DubbAddonCell.h
//  Dubb
//
//  Created by andikabijaya on 5/11/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbGigQuantityCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) NSDictionary *addonInfo;
@property (nonatomic) NSInteger quantity;

- (void)initViewWithAddonInfo:(NSDictionary *)addonInfo;
@end
