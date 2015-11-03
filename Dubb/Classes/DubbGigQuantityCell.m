//
//  DubbAddonCell.m
//  Dubb
//
//  Created by andikabijaya on 5/11/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbGigQuantityCell.h"

@implementation DubbGigQuantityCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initViewWithAddonInfo:(NSDictionary *)addonInfo {
    
    self.addonInfo = addonInfo;
    
}

- (IBAction)plusButtonTapped:(id)sender {
    
    self.quantity ++;
    self.quantityLabel.text = [NSString stringWithFormat:@"%ld", self.quantity];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapPlusButton object:nil userInfo:self.addonInfo];
    
    
}
- (IBAction)minusButtonTapped:(id)sender {
    
    if (self.quantity > 1) {
        
        self.quantity --;
        self.quantityLabel.text = [NSString stringWithFormat:@"%ld", self.quantity];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapMinusButton object:nil userInfo:self.addonInfo];
        
    }
    
}

@end
