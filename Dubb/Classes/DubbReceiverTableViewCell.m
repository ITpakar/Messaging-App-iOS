//
//  DubbReceiverTableViewCell.m
//  Dubb
//
//  Created by Oleg Koshkin on 13/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbReceiverTableViewCell.h"
#import "AsyncImageView.h"

@interface DubbReceiverTableViewCell(){
    
    __weak IBOutlet AsyncImageView *profileImageView;
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UIImageView *bubbleImageView;
}
@end

@implementation DubbReceiverTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setupCell
{
    UIImage *image = [UIImage imageNamed:@"receiver_bubble.png"];
    UIImage *cellBGImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(40, 25, 15, 25) resizingMode:UIImageResizingModeStretch];
    bubbleImageView.image = cellBGImage;
    
    
    profileImageView.showActivityIndicator = YES;
    profileImageView.image = nil;

    if( self.profileImage == nil  )
        profileImageView.image = [UIImage imageNamed:@"portrait.png"];
    else
        profileImageView.image = self.profileImage;
    
    messageTextView.text = self.message;
    lblTime.text = lblTime.text = self.localTime;
}


@end
