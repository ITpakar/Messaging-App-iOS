//
//  ListingTopView.h
//  Dubb
//
//  Created by andikabijaya on 5/7/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DubbSingleListingViewController.h"
#import "KASlideShow.h"
#import "MCPercentageDoughnutView.h"

@interface ListingTopView : UIView
@property (strong, nonatomic) IBOutlet KASlideShow *slideShow;

@property (strong, nonatomic) IBOutlet UIView *extraControlsContainerView;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet MCPercentageDoughnutView *downloadProgressView;
@property (strong, nonatomic) IBOutlet MCPercentageDoughnutView *imageProgressView;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;

@property (strong, nonatomic) IBOutlet UIImageView *placeholderImageView;

@property (nonatomic) NSInteger imagesCount;
@property (nonatomic) NSArray *imageInfoSet;
@property (strong, nonatomic) DubbSingleListingViewController *parentViewController;
-(void)updatePageLabel;
-(void) setDownloadProgress:(CGFloat)progress;
- (void)initViews;
- (void)initImagesWithInfoArray:(NSArray *)imageInfoSet ;
@end
