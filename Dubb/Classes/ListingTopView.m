//
//  ListingTopView.m
//  Dubb
//
//  Created by andikabijaya on 5/7/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import "ListingTopView.h"

@implementation ListingTopView
@synthesize downloadProgressView;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initViews {
    
    [self.slideShow setTransitionType:KASlideShowTransitionSlide]; // Choose a transition type (fade or slide)
    [self.slideShow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    [self.slideShow addGesture:KASlideShowGestureAll];
    
    downloadProgressView.percentage              = 0;
    downloadProgressView.linePercentage          = 0.15;
    downloadProgressView.animationDuration       = 0;
    downloadProgressView.showTextLabel           = NO;
    downloadProgressView.animatesBegining        = NO;
}

-(void)updatePageLabel {
    self.pageControl.currentPage = self.slideShow.currentIndex;
    self.pageControl.numberOfPages = self.imagesCount;

    NSDictionary *imageInfo = self.imageInfoSet[self.slideShow.currentIndex];
    if ([imageInfo[@"type"] isEqualToString:@"video"]) {
        downloadProgressView.hidden = NO;
    } else {
        downloadProgressView.hidden = YES;
    }
}

- (void)initImagesWithInfoArray:(NSArray *)imageInfoSet {
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    for (NSDictionary* imageInfo in imageInfoSet) {
        NSString *url = [imageInfo[@"type"] isEqualToString:@"video"] ? imageInfo[@"preview"] : imageInfo[@"url"];

        NSURL* _url = [self.parentViewController prepareImageUrl:url];

        [manager downloadImageWithURL:_url
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    if (self.placeholderImageView.hidden == NO) {
                                        self.placeholderImageView.hidden = YES;
                                    }
                                    [self.slideShow addImage:image];
                                }
                            }];
    }
    
    self.imagesCount = imageInfoSet.count;
    self.imageInfoSet = imageInfoSet;
    [self updatePageLabel];
}

-(void) setDownloadProgress:(CGFloat)progress {
    downloadProgressView.percentage = progress;
}
- (IBAction)playButtonTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapPlayButton object:nil userInfo:@{@"cell":self}];
}

@end
