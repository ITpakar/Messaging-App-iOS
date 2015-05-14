//
//  DubbAddonCell.h
//  Dubb
//
//  Created by andikabijaya on 5/11/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbAddonCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;

@property (weak, nonatomic) NSDictionary *addonInfo;
@property (nonatomic) BOOL checked;

- (void)initViewWithAddonInfo:(NSDictionary *)addonInfo;
@end
