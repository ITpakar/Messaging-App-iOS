//
//  BackendBase.m
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "BackendBase.h"
#import "AFNetworking.h"

static BackendBase   *sharedConnection;

@implementation BackendBase

- (void) accessAPI:(NSString *)apiPath
        Parameters:(NSDictionary *)params
 CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:apiPath]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager GET:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        id response = [NSJSONSerialization JSONObjectWithData: responseObject options:NSJSONReadingMutableContainers error:nil];
        handler(response, nil, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        handler(nil, nil, error);
    }];
    
}

- (void) accessAPIbyPost:(NSString *)apiPath
        Parameters:(NSDictionary *)params
 CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:apiPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        id response = [NSJSONSerialization JSONObjectWithData: responseObject options:NSJSONReadingMutableContainers error:nil];
        handler(response, nil, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        handler(nil, nil, error);
    }];
    
}

- (void)accessAPIbyPOST:(NSString *)apiPath
             Parameters:(NSDictionary *)params
      CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler
{
    
    /*AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:apiPath]];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFPropertyListRequestSerializer serializer];

   
    [manager POST:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {

        id response = [NSJSONSerialization JSONObjectWithData: responseObject options:NSJSONReadingMutableContainers error:nil];
        
        handler(response, nil, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        handler(nil, nil, error);
    }];*/
    NSString *postString = @"";
    
    for (NSString *key in params) {
        postString = [NSString stringWithFormat:@"%@=%@&%@", key, [params objectForKey:key], postString];
    }
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:apiPath]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data != nil)
                               {
                                   NSError *myError = nil;
                                   NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                                          options:NSJSONReadingMutableLeaves error:&myError];
                                   
                                   if( result && result[@"error"] && [result[@"error"] boolValue] == false)
                                       handler(result, nil, nil);
                                   else
                                       handler(nil, nil, nil);
                                   
                               }
                               else
                               {
                                   handler(nil, nil, nil);
                               }
                           }];

}

- (void)accessAPIbyPUT:(NSString *)apiPath
             Parameters:(NSDictionary *)params
      CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler
{
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    [manager PUT:apiPath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        id response = [NSJSONSerialization JSONObjectWithData: responseObject options:NSJSONReadingMutableContainers error:nil];
        
        handler(response, nil, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        handler(nil, nil, error);
    }];
}

- (void)accessAPIbyDELETE:(NSString *)apiPath
             Parameters:(NSDictionary *)params
      CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler
{
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:apiPath]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    
    [manager DELETE:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        id response = [NSJSONSerialization JSONObjectWithData: responseObject options:NSJSONReadingMutableContainers error:nil];
        
        handler(response, nil, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        handler(nil, nil, error);
    }];
}

- (void)uploadImagebyPost:(NSString *)apiPath
               Parameters:(NSDictionary *)params
                    Image:(UIImage*) image
                 filename:(NSString*)filename
        CompletionHandler:(void (^)(NSDictionary *result, NSData *data, NSError *error))handler
{
    
    NSString *requestURL = [NSString stringWithFormat:@"%@", apiPath];
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"img.jpg\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];    
    [body appendData:[NSData dataWithData: UIImageJPEGRepresentation(image, 0.8f) ]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"api\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];

    
    for (NSString *key in params) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[params objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (data != nil)
                               {
                                   
                                   NSError *myError = nil;
                                   NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                                          options:NSJSONReadingMutableLeaves error:&myError];
                                   
                                   handler(result, data, connectionError);
                               }
                               else
                               {
                                   handler(nil, nil, nil);
                               }
                           }];
    
    
    

}


@end

