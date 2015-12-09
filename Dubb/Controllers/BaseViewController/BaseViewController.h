//
//  BaseViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHPBackend.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>
#import "Cloudinary/Cloudinary.h"

@interface BaseViewController : UIViewController 

@property BackendBase           *backend;
@property CLCloudinary *cloudinary;
@property(nonatomic, strong) NSString *reasonForDisablingMenu;
- (id)initialize;
- (void)showMessage : (NSString *)message;
- (void)showCreateListingTableViewController ;
- (void)showAlertForLogIn;
- (void)showLoginView;
- (NSURL*)prepareVideoUrl:(NSString*)url;
- (NSURL*)prepareImageUrl:(NSString*)url;
- (NSURL*)prepareImageUrl:(NSString*)url size:(CGSize) size gravity:(NSString*)gravity;
- (NSURL*)prepareImageUrl:(NSString*)url size:(CGSize) size;
- (NSURL*)prepareImageUrl:(NSString*)url withWith:(int)width withHeight:(int)height withGravity:(NSString*)gravity;
- (void) uploadImage:(UIImage *)image CompletionHandler:(void (^)(NSString *urlString)) handler;
- (void)uploadFileWithFileName:(NSString *)fileName SourcePath:(NSString *)sourcePath FileURL:(NSURL *)fileURL Type:(NSString*) type CompletionHandler:(void (^)(NSString *urlString)) handler;
//MB Progres
- (void)showProgress:(NSString *)message;
- (void)hideProgress;

@end
