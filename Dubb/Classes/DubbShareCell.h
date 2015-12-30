//
//  DubbShareCell.h
//  Dubb
//
//  Created by andikabijaya on 12/30/15.
//  Copyright © 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbShareCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@end
