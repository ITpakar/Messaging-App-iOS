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
        if (handler) {
            handler(result);
        }
    }];
}

-(void) getUser : (NSString*) userID
         CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@%@", APIURL, @"user/",userID];
    NSDictionary *params = @{@"with":@"preferences"};
    
    [self accessAPI:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        if (handler) {
            handler(result);
        }
        
    }];
}
-(void) updateListing : (NSString*) listingID
        Parameters : (NSDictionary*) params
  CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", @"listing/", listingID];
    
    [self accessAPIbyPUT:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        if (handler) {
            handler(result);
        }
    }];
}

-(void) getSuggestionList : (NSString*) keyword
         CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"search/suggest"];

    User *user = [User currentUser];
    NSDictionary *params = @{@"q":keyword, @"from":@"tags", @"t_user_id":user.userID, @"t_latitude":user.latitude, @"t_longtitude":user.longitude};
    
    [self accessAPI:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        if (handler) {
            handler(result);
        }

    }];
}

-(void) getAllListings: (NSString*)page CompletionHandler:(void (^)(NSDictionary *result))handler{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"listing"];

    User *user = [User currentUser];
    NSDictionary *params = @{@"page":page, @"limit":@"25", @"with":@"user,mainimage,category", @"t_user_id":user.userID, @"t_latitude":user.latitude, @"t_longtitude":user.longitude};
    
    [self accessAPI:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}

-(void) getAllListings: (NSString*)keyword Page:(NSString*)page CompletionHandler:(void (^)(NSDictionary *result))handler{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"search"];

    User *user = [User currentUser];
    NSDictionary *params = @{@"start":page, @"size":@"25", @"q":keyword, @"t_user_id":user.userID, @"t_latitude":user.latitude, @"t_longtitude":user.longitude};
    
    [self accessAPI:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}


-(void) getAllCategories :(void (^)(NSDictionary *result))handler{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"categories"];
    [self accessAPI:apiPath Parameters:nil CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}


-(void) getListingsWithCategoryID : (NSString*) category_id Page:(NSInteger)page CompletionHandler:(void (^)(NSDictionary *result))handler
{
    User *user = [User currentUser];
    NSString *apiPath = [NSString stringWithFormat:@"%@category/%@/listing?sortby=created_at&order=desc&page=%lu&limit=25&t_user_id=%@&t_latitude=%@&t_longtitude=%@", APIURL, category_id, page, user.userID, user.latitude, user.longitude];
    [self accessAPI:apiPath Parameters:nil CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}


-(void) getListingWithID:(NSString *)listingID CompletionHandler:(void (^)(NSDictionary *result))handler{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@/%@", APIURL, @"listing", listingID];

    User *user = [User currentUser];
    NSDictionary *params = @{@"with":@"user,category,mainimage,images,addon", @"t_user_id":user.userID, @"t_latitude":user.latitude, @"t_longtitude":user.longitude};
    
    [self accessAPI:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}


-(void) checkValidityOfUsernameOrEmail:(NSString *)userNameOrEmail CompletionHandler:(void (^)(NSDictionary *result))handler{
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@/%@", APIURL, @"user", userNameOrEmail];
    
    [self accessAPI:apiPath Parameters:nil CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        if (handler) {
            handler(result);
        }

    }];
    
}

-(void) registerDeviceToken:(NSString *)deviceToken forUser:(NSString *)userID
         CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"device"];
    
    [self accessAPIbyPOST:apiPath Parameters:@{@"user_id": userID, @"token": deviceToken} CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        if (handler) {
            handler(result);
        }
    }];
}

-(void) createOrder:(NSDictionary*)params
         CompletionHandler:(void (^)(NSDictionary *result))handler
{
    NSString *apiPath = [NSString stringWithFormat:@"%@", @"order"];
    
    [self accessAPIbyPost:apiPath Parameters:params CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}

-(void) getAllOrdersForUserType:(NSString *)userType CompletionHandler:(void (^)(NSDictionary *result))handler{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"order"];
    [self accessAPI:apiPath Parameters:@{@"user_id":[User currentUser].userID, @"user_type":userType, @"with":@"listing,listing.mainImage,listing.user,details.addon"} CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}

-(void) getAllMyListingsWithCompletionHandler:(void (^)(NSDictionary *result))handler{
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", APIURL, @"listing"];
    [self accessAPI:apiPath Parameters:@{@"user_id":[User currentUser].userID} CompletionHandler:^(NSDictionary *result, NSData *data, NSError *error) {
        handler(result);
    }];
}

@end
