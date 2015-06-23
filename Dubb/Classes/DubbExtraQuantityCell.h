//
//  DubbExtraQuantityCell.h
//  Dubb
//
//  Created by andikabijaya on 6/17/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbExtraQuantityCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;

@property (weak, nonatomic) NSDictionary *addonInfo;
@property (nonatomic) NSInteger quantity;

- (void)initViewWithAddonInfo:(NSDictionary *)addonInfo;
@end
