//
//  DubbChatCell.h
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    DubbMessageTypeText    = 0,
    DubbMessageTypePicture = 1,
    DubbMessageTypeVideo   = 2
} DubbMessageType;

@interface DubbChatCell : UITableViewCell

@property UIImage* profileImage;
@property QBChatMessage *message;
@property DubbMessageType messageType;

@property BOOL isTransferred;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            Message:(QBChatMessage*) message ProfileImage:(UIImage*)image;
-(void) setup;

@end
