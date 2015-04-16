//
//  DubbSenderTableViewCell.m
//  Dubb
//
//  Created by Oleg Koshkin on 13/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbSenderTableViewCell.h"
#import "AsyncImageView.h"
#import "User.h"

@interface DubbSenderTableViewCell(){
    
    __weak IBOutlet AsyncImageView *profileImageView;
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UIImageView *bubbleImageView;
    
}
@end

@implementation DubbSenderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UIImage *image = [UIImage imageNamed:@"sender_bubble.png"];
    UIImage *cellBGImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(40, 25, 15, 25) resizingMode:UIImageResizingModeStretch];
    bubbleImageView.image = cellBGImage;
    profileImageView.image = [User currentUser].profileImage;
    if(profileImageView.image == nil) profileImageView.image = [UIImage imageNamed:@"portrait.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setupCell
{
    profileImageView.showActivityIndicator = YES;
    profileImageView.image = nil;
    
    if( self.profileImage == nil  )
        profileImageView.image = [UIImage imageNamed:@"portrait.png"];
    else
        profileImageView.image = self.profileImage;
    
    messageTextView.text = self.message.text;
}



@end
