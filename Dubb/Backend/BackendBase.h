//
//  BackendBase.h
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackendBase : NSObject

+ (BackendBase *)sharedConnection;

- (id)init;

- (void)loginWithUsername:(NSDictionary*) params
        CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) registerWithSocial:(NSDictionary*)params
         CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) resetPassword:(NSDictionary*) params
        CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) updateUser : (NSString*) userID Parameters : (NSDictionary*) params
  CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) getUser : (NSString*) userID
CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) getSuggestionList : (NSString*) keyword
  CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) getAllListings: (NSString*)page CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) getAllListings: (NSString*)keyword Page:(NSString*)page CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) getAllCategories :(void (^)(NSDictionary *result))handler;

-(void) getListingsWithCategoryID : (NSString*) category_id Page:(NSInteger)page CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) getListingWithID:(NSString *)listingID CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) updateListing : (NSString*) listingID Parameters : (NSDictionary*) params CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) checkValidityOfUsernameOrEmail:(NSString *)userNameOrEmail CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) registerDeviceToken:(NSString *)deviceToken forUser:(NSString *)userID CompletionHandler:(void (^)(NSDictionary *result))handler;

-(void) createOrder:(NSDictionary*)params CompletionHandler:(void (^)(NSDictionary *result))handler;
/* Common functions for all backends */

- (void) accessAPIbyPost:(NSString *)apiPath
              Parameters:(NSDictionary *)params
       CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler;

- (void) accessAPI:(NSString *)apiPath
        Parameters:(NSDictionary *)params
 CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler;

- (void)accessAPIbyPOST:(NSString *)apiPath
             Parameters:(NSDictionary *)params
      CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler;

- (void)accessAPIbyPUT:(NSString *)apiPath
             Parameters:(NSDictionary *)params
      CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler;

- (void)accessAPIbyDELETE:(NSString *)apiPath
            Parameters:(NSDictionary *)params
     CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler;

- (void)uploadImagebyPost:(NSString *)apiPath
               Parameters:(NSDictionary *)params
                    Image:(UIImage*) image
                 filename:(NSString*)filename
      CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler;
-(void) getAllOrdersForUserType:(NSString *)userType CompletionHandler:(void (^)(NSDictionary *result))handler;
-(void) getAllMyListingsWithCompletionHandler:(void (^)(NSDictionary *result))handler;
@end
