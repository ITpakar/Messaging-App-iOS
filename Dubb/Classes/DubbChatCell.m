//
//  DubbChatCell.m
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbChatCell.h"

@implementation DubbChatCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setTimestamp:(NSDate *)timestamp
{
    static NSDateFormatter *messageDateFormatter;
    if( messageDateFormatter == nil ){
        messageDateFormatter = [[NSDateFormatter alloc] init];
        [messageDateFormatter setDateFormat: @"HH:mm a"];
        [messageDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:[User currentUser].timeZone*60*60]];
    }
    _localTime = [messageDateFormatter stringFromDate:timestamp];

}

@end
