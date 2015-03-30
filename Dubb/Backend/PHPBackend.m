//
//  PHPBackend.m
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "PHPBackend.h"

static PHPBackend   *sharedConnection;

@implementation PHPBackend

+ (BackendBase *)sharedConnection
{
    if (sharedConnection == nil)
        sharedConnection = [PHPBackend new];
    return sharedConnection;
}

- (id)init
{
    self = [super init];
    return self;
}

- (void)loginWithUsername:(NSDictionary*) params
        CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"auth/signin"];
    
    [self accessAPIbyPOST:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}

-(void) registerWithSocial:(NSDictionary*)params
         CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"auth/signup"];
    
    [self accessAPIbyPOST:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}

-(void) updateUser : (NSString*) userID
        Parameters : (NSDictionary*) params
  CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@%@", APIURL, @"user/", userID];
    
    [self accessAPIbyPUT:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}


@end
