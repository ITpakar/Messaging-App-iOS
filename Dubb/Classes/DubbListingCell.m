//
//  DubbListingCell.m
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbListingCell.h"
#import "AXRatingView.h"
#import "MCPercentageDoughnutView.h"
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DubbListingCell(){
    IBOutlet UIView*         containerView;
    IBOutlet UIImageView*    profileImageView;
    IBOutlet UILabel*        titleLabel;
    IBOutlet UILabel*        userLabel;
    IBOutlet UILabel*        locationLabel;
    IBOutlet UIImageView*    listingImageView;
    IBOutlet UILabel*        categoryLabel;
    IBOutlet UIButton*       btnOrder;
    IBOutlet AXRatingView *starRatingControl;
    IBOutlet UILabel *priceLabel;
    IBOutlet MCPercentageDoughnutView *downloadProgressView;
    IBOutlet UILabel *distanceLabel;
    
    UIActivityIndicatorView *mainImageIndicator;
    
}

@end

@implementation DubbListingCell

-(void) initWithListingInfo:(NSDictionary*)listing{

    if(self){
        self.baseVC = [[BaseViewController alloc] initialize];

        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _listing = [[NSDictionary alloc] initWithDictionary:listing];
        
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.borderColor = [UIColor colorWithRed:215.0f/255.0f green:216.0f/255.0f blue:222.0f/255.0f alpha:1.0f].CGColor;
        
        profileImageView.layer.borderColor = [UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0f].CGColor;
        
        mainImageIndicator = [[UIActivityIndicatorView alloc] init];
        mainImageIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
        downloadProgressView.percentage              = 0;
        downloadProgressView.linePercentage          = 0.15;
        downloadProgressView.animationDuration       = 0;
        downloadProgressView.showTextLabel           = NO;
        downloadProgressView.animatesBegining        = NO;

        
        starRatingControl.backgroundColor = [UIColor clearColor];
        starRatingControl.markImage = [UIImage imageNamed:@"star"];
        starRatingControl.stepInterval = 1;
        starRatingControl.value = 5;
        [starRatingControl setBaseColor:[UIColor lightGrayColor]];
        [starRatingControl setHighlightColor:[UIColor colorWithRed:245/255.0f green:221.0f/255.0 blue:18/255.0f alpha:1.0f]];
        [starRatingControl setUserInteractionEnabled:NO];

        
        NSString *username = _listing[@"username"] ?: @"Unknown";
        userLabel.text = [NSString stringWithFormat:@"%@%@",[[username substringToIndex:1] uppercaseString], [username substringFromIndex:1]];
        
        @try{
            if ([_listing[@"user"] objectForKey:@"image"]) {
                if ([_listing[@"user"][@"image"] isKindOfClass:[NSNull class]]) {
                    profileImageView.image = [UIImage imageNamed:@"portrait.png"];
                } else {
                    [profileImageView sd_setImageWithURL:[self.baseVC prepareImageUrl:_listing[@"user"][@"image"][@"url"] withWith:200 withHeight:200 withGravity:@"face"]];
                }
            } else {
                if (![_listing objectForKey:@"owner_image_url"] || [_listing[@"owner_image_url"] isKindOfClass:[NSNull class]]) {
                    profileImageView.image = [UIImage imageNamed:@"portrait.png"];
                } else {
                    [profileImageView sd_setImageWithURL:[self.baseVC prepareImageUrl:_listing[@"owner_image_url"] withWith:200 withHeight:200 withGravity:@"face"]];
                }
            }
            
            titleLabel.text = [NSString stringWithFormat:@"%@%@",[[listing[@"name"] substringToIndex:1] uppercaseString], [listing[@"name"] substringFromIndex:1]];
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocationCoordinate2D myCoOrdinate;
            myCoOrdinate.latitude = [[listing[@"latlon"] componentsSeparatedByString:@","][0] floatValue];
            myCoOrdinate.longitude = [[listing[@"latlon"] componentsSeparatedByString:@","][1] floatValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:myCoOrdinate.latitude longitude:myCoOrdinate.longitude];
            
            [geocoder reverseGeocodeLocation:location completionHandler: ^ (NSArray  *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks firstObject];
                if(placemark) {
                    //NSMutableString *location = [[NSMutableString alloc] init];
                    NSString *location = @"";
                    @try{
                        if( placemark.addressDictionary[(NSString*)kABPersonAddressCityKey] && placemark.addressDictionary[(NSString*)kABPersonAddressStateKey])
                            location = [NSString stringWithFormat:@"%@, %@", placemark.addressDictionary[(NSString*)kABPersonAddressCityKey], placemark.addressDictionary[(NSString*)kABPersonAddressStateKey]];
                        locationLabel.text = location;
                        
                    }@catch(NSException *e){
                        
                    }
                    
                }
            }];
            
            NSMutableString *category = [[NSMutableString alloc] init];
            
            if( _listing[@"category"] && ![_listing[@"category"] isKindOfClass:[NSNull class]] )
                [category appendString: _listing[@"category"]];
            
            if( _listing[@"sub_category"] && ![_listing[@"sub_category"] isKindOfClass:[NSNull class]] )
                [category appendFormat:@" > %@", _listing[@"sub_category"]];
            
            categoryLabel.text = [category uppercaseString];

            CGSize imageViewSize = CGSizeMake(self.listingImageViewFrame.size.width * 2, self.listingImageViewFrame.size.height * 2);
            
            if( listing[@"main_video_preview"] && ![listing[@"main_video_preview"] isKindOfClass:[NSNull class]] ){
                [listingImageView sd_setImageWithURL:[self.baseVC prepareImageUrl:listing[@"main_video_preview"] size:imageViewSize gravity:@"face"]];
                downloadProgressView.hidden = NO;
            }
            else if( listing[@"main_image"] && ![listing[@"main_image"] isKindOfClass:[NSNull class]] ){
                downloadProgressView.hidden = YES;
                if( [listing[@"main_image"] isKindOfClass:[NSString class]] && listing[@"main_image"] ){
                    [mainImageIndicator startAnimating];
                    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[[self.baseVC prepareImageUrl:listing[@"main_image"] size:imageViewSize gravity:@"face"] absoluteString] done:^(UIImage *image, SDImageCacheType cacheType) {
                        /*if( image != nil){
                            listingImageView.image = image;
                            [mainImageIndicator stopAnimating];
                        } else*/ {
                            [SDWebImageDownloader.sharedDownloader downloadImageWithURL: [self.baseVC prepareImageUrl:listing[@"main_image"] size:imageViewSize gravity:@"face"] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [mainImageIndicator stopAnimating];
                                    if( error == nil ){
                                        listingImageView.image = image;
                                        [[SDImageCache sharedImageCache] storeImage:image forKey:[[self.baseVC prepareImageUrl:listing[@"main_image"] size:imageViewSize gravity:@"face"] absoluteString]];
                                    } else {
                                        listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
                                        [[SDImageCache sharedImageCache] storeImage:listingImageView.image forKey:[[self.baseVC prepareImageUrl:listing[@"main_image"] size:imageViewSize  gravity:@"face"] absoluteString]];
                                    }
                                    [listingImageView layoutIfNeeded];
                                });
                                
                            }];
                        }
                    }];
                    
                }
                else
                    listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
                
            } else
                listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
           
            priceLabel.text = [NSString stringWithFormat:@"$%ld", [listing[@"baseprice"] integerValue] ];
//            if( listing[@"baseprice"] )
//                [btnOrder setTitle:[NSString stringWithFormat:@"ORDER $%d", (int)[listing[@"baseprice"] integerValue]]  forState:UIControlStateNormal];
//            else
//                [btnOrder setTitle:@"ORDER $20" forState:UIControlStateNormal];
            distanceLabel.text = [NSString stringWithFormat:@"%ld mi", [listing[@"distance"] integerValue]];

        }@catch(NSException *e){
            
            profileImageView.image = [UIImage imageNamed:@"portrait.png"];
            listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
//            [btnOrder setTitle:@"ORDER $20" forState:UIControlStateNormal];
            
            NSLog(@"Exception: %@", e.description);
        }
    }
}

-(void) layoutSubviews {
    self.listingImageViewFrame = listingImageView.frame;

    UIBezierPath* shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(8, 250.0f)];
    [shadowPath addLineToPoint:CGPointMake(304, 255.0f)];
    [shadowPath closePath];
    
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOpacity = 0.5f;
    containerView.layer.shadowRadius = 4.0f;
    [containerView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    //containerView.layer.shadowPath = shadowPath.CGPath;
    
    mainImageIndicator.center = listingImageView.center;
    
    [self addGradientToView:listingImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)addGradientToView:(UIView*)view
{
    //add in the gradient to show scrolling
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = [UIColor colorWithWhite:0.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
    
    maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                        (__bridge id)innerColor, nil];
    maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer.bounds = CGRectMake(0, 0, sWidth - 16, 191.0f);
    maskLayer.anchorPoint = CGPointZero;
    
    [view.layer addSublayer:maskLayer];
    
}
-(void) setDownloadProgress:(CGFloat)progress {
    downloadProgressView.percentage = progress;
}
- (IBAction)playButtonTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapPlayButton object:nil userInfo:@{@"cell":self}];
}
@end
