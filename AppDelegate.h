//
//  AppDelegate.h
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#define awsAccessKey @"AKIAIG3EJECQJIFIE3LA"
#define awsSecretKey @"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"

#import <UIKit/UIKit.h>
#import "NotificationView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NotificationDelegate, QBActionStatusDelegate, CLLocationManagerDelegate>

-(void)registerForRemoteNotifications;

-(void)didReceiveMessage: (QBChatMessage*) message;
-(void)updateUserLocation;@property (strong, nonatomic) UIWindow *window;

@property (strong) NotificationView *notificationView;



@end

