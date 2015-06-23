//
//  DubbAddonCell.m
//  Dubb
//
//  Created by andikabijaya on 5/11/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbAddonCell.h"

@implementation DubbAddonCell

- (void)awakeFromNib {
    // Initialization code
    self.checked = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        
        [self.checkButton setImage:[UIImage imageNamed:@"addon_checked"] forState:UIControlStateNormal];
        self.checked = YES;
        
    }

}

- (void)initViewWithAddonInfo:(NSDictionary *)addonInfo {
    

    self.priceLabel.text = [NSString stringWithFormat:@"$%ld", [addonInfo[@"price"] integerValue]];
    self.descriptionLabel.text = addonInfo[@"description"];
    
    self.addonInfo = addonInfo;
    

}

- (IBAction)checkToggleButtonTapped:(id)sender {
    
    self.checked = !self.checked;
    
    NSString *notificationKey = self.checked == YES ? kNotificationDidCheckAddon : kNotificationDidUncheckAddon;
    NSString *buttonImageName = self.checked == YES ? @"addon_checked" : @"addon_unchecked";
    
    [self.checkButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey object:nil userInfo:self.addonInfo];

    
}
@end
