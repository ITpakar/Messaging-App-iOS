//
//  DubbMyListingCell.h
//  Dubb
//
//  Created by andikabijaya on 10/21/15.
//  Copyright © 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbMyListingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *postedDateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *progressIndicatorImageView;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@end
