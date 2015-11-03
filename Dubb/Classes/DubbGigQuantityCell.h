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

@property (weak, nonatomic) NSDictionary *addonInfo;
@property (weak, nonatomic) NSString *title;
@property (nonatomic) NSInteger quantity;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *addonQuantityContainer;


- (void)initViewWithAddonInfo:(NSDictionary *)addonInfo;
@end
