//
//  User.h
//  Dubb
//
//  Created by Oleg Koshkin on 13/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickBlox/QuickBlox.h>

@interface User : NSObject

+(User*) currentUser;
+(User*) initialize:(NSDictionary*) dic;
-(void) initialize;


@property NSString* userID;
@property NSString* username;
@property NSString* firstName;
@property NSString* lastName;
@property NSString* email;
@property NSString* gender;
@property NSString* gpID;
@property NSString* fbID;
@property NSString* quickbloxID;

@property (nonatomic) NSInteger timeZone;
@property NSDateFormatter *dateFormatter;
@property NSInteger ageRange;

@property NSNumber* longitude;
@property NSNumber* latitude;
@property NSString* zipCode;
@property NSString* countryCode;
@property (nonatomic, strong) NSString* street;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* country;


@property (nonatomic, strong) UIImage *profileImage;

@property (nonatomic, strong) QBUUser* chatUser;

@property (nonatomic, strong) NSArray *chatUsers;
@property (nonatomic, strong) NSMutableDictionary *usersAsDictionary;
@property (nonatomic, strong) NSMutableDictionary *avatarsAsDictionary;

@end
