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
    [self.slideShow addGesture:KASlideShowGestureSwipe];
}

-(void)updatePageLabel {
    
    [self.pageLabel setText:[NSString stringWithFormat:@"%lu / %lu", self.slideShow.currentIndex + 1, (unsigned long)self.imagesCount]];
}

- (void)initImagesWithInfoArray:(NSArray *)imageInfoSet {
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    for (NSDictionary* imageInfo in imageInfoSet) {
        [manager downloadImageWithURL:imageInfo[@"url"]
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
    [self updatePageLabel];
}
- (IBAction)flagButtonTapped:(id)sender {
    
    [self.parentViewController flagButtonTapped];
    
    
}

@end
