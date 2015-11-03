//
//  DubbCategoryCell.m
//  Dubb
//
//  Created by Oleg K on 5/13/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbCategoryCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DubbCategoryCell()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;

@end

@implementation DubbCategoryCell

-(void) setupCell : (NSDictionary*) category
{
   
    _categoryData = category;
    
    _containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _containerView.layer.shadowRadius = 3.0f;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_containerView.bounds];
    _containerView.layer.shadowPath = shadowPath.CGPath;
    
    _categoryNameLabel.text = category[@"name"];
    
    [_activityIndicator stopAnimating];
    if( [_categoryData[@"url"] isKindOfClass:[NSNull class]] )
        _categoryImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
    else {
        
        [_activityIndicator startAnimating];
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:_categoryData[@"url"] done:^(UIImage *image, SDImageCacheType cacheType) {
            if( image != nil){
                [_activityIndicator stopAnimating];
                _categoryImageView.image = image;
            } else {
                [SDWebImageDownloader.sharedDownloader downloadImageWithURL: [NSURL URLWithString:_categoryData[@"url"]] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    [_activityIndicator stopAnimating];
                    
                    if( image == nil )
                        image = [UIImage imageNamed:@"placeholder_image.png"];
                    
                    _categoryImageView.image = image;
                    [[SDImageCache sharedImageCache] storeImage:image forKey:_categoryData[@"url"]];
                }];
            }
        }];
    }
}

@end
