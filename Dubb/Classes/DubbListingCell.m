//
//  DubbListingCell.m
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbListingCell.h"

@interface DubbListingCell(){
    UIView*         containerView;
    UIImageView*    profileImageView;
    UILabel*        titleLabel;
    UILabel*        userLabel;
    UIImageView*    listingImageView;
    UILabel*        categoryLabel;
    UIButton*       btnOrder;
    
}

@end

@implementation DubbListingCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.masksToBounds = NO;
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOpacity = 0.5f;
        
        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 3.0f;
        profileImageView.image = [UIImage imageNamed:@"portrait.png"];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont systemFontOfSize:14.0f weight:bold];
        titleLabel.text = @"I will take professional head shots in my studio";
        
        
        userLabel = [[UILabel alloc] init];
        NSMutableAttributedString *userText = [[NSMutableAttributedString alloc] initWithString:@"ezrasp Los Angeles, CA" attributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName: [UIFont systemFontOfSize:12.0f]}];
        [userText addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, 6)];
        userLabel.attributedText = userText;
        
        listingImageView = [[UIImageView alloc] init];
        listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
        
        categoryLabel = [[UILabel alloc] init];
        categoryLabel.font = [UIFont systemFontOfSize:14.0f];
        categoryLabel.textColor = [UIColor darkGrayColor];
        categoryLabel.text = @"Food Entertainment / Personal";
        
        btnOrder = [[UIButton alloc] init];
        btnOrder.layer.masksToBounds = YES;
        btnOrder.layer.cornerRadius = 10.0f;
        btnOrder.layer.borderColor = [UIColor whiteColor].CGColor;
        btnOrder.layer.borderWidth = 1.0f;
        
        [btnOrder setTitle:@"ORDER ($20)" forState:UIControlStateNormal];
        [btnOrder setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f] forState:UIControlStateNormal];
        [btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnOrder.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [btnOrder.titleLabel setShadowOffset:CGSizeMake(1, 1)];
        [btnOrder setBackgroundColor:[UIColor colorWithRed:1.0f green:0.67f blue:0.21 alpha:1.0f]];
        
        [containerView addSubview:profileImageView];
        [containerView addSubview:titleLabel];
        [containerView addSubview:userLabel];
        [containerView addSubview:listingImageView];
        [containerView addSubview:categoryLabel];
        [containerView addSubview:btnOrder];
        
        [self.contentView addSubview:containerView];

    }
    
    return self;
}

-(void) layoutSubviews {
    
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    [containerView setFrame:CGRectMake(10, 8, width - 20, height - 16)];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:containerView.bounds];
    containerView.layer.shadowPath = shadowPath.CGPath;
    
    [titleLabel setFrame:CGRectMake(60, 10, width - 90, 35)];
    [userLabel setFrame:CGRectMake(60, 42, width - 90, 14)];
    [listingImageView setFrame:CGRectMake(15, 64, width-45, height - 106)];
    [btnOrder setFrame:CGRectMake(width - 120, height - 70, 80, 20)];
    [categoryLabel setFrame:CGRectMake(15, height - 42, width-25, 26)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
