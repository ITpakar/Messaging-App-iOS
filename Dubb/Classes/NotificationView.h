//
//  NotificationView.h
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotificationView;

@protocol NotificationDelegate

-(void) openMessage : (NSDictionary*) messageInfo;

@end

@interface NotificationView : UIView

@property NSDictionary *messageInfo;
@property (nonatomic, assign) id delegate;
@property BOOL isShowing;

-(void) showMessage: (NSString*) msg;
-(void) hideNotification;

@end
