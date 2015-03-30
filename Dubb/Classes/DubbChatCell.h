//
//  DubbChatCell.h
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbChatCell : UITableViewCell

@property NSString* message;
@property UIImage* profileImage;
@property (nonatomic, strong) NSDate* timestamp;
@property (nonatomic, strong) NSString *localTime;

-(void) setupCell;

@end
