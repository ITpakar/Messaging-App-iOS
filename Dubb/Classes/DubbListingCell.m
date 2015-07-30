//
//  DubbListingCell.m
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbListingCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DubbListingCell(){
    UIView*         containerView;
    UIImageView*    profileImageView;
    UILabel*        titleLabel;
    UILabel*        userLabel;
    UIImageView*    listingImageView;
    UILabel*        categoryLabel;
    UIButton*       btnOrder;
    
    UIActivityIndicatorView *mainImageIndicator;
    
}

@end

@implementation DubbListingCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier listingInfo:(NSDictionary*)listing{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _listing = [[NSDictionary alloc] initWithDictionary:listing];
        
        containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.masksToBounds = NO;
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOpacity = 0.5f;
        
        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = 3.0f;
        
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont systemFontOfSize:14.0f weight:bold];
        
        
        
        listingImageView = [[UIImageView alloc] init];
        listingImageView.contentMode = UIViewContentModeScaleAspectFill;
        listingImageView.clipsToBounds = YES;
        
        mainImageIndicator = [[UIActivityIndicatorView alloc] init];
        mainImageIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        categoryLabel = [[UILabel alloc] init];
        categoryLabel.font = [UIFont systemFontOfSize:14.0f];
        categoryLabel.textColor = [UIColor darkGrayColor];

        btnOrder = [[UIButton alloc] init];
        btnOrder.layer.masksToBounds = YES;
        btnOrder.layer.cornerRadius = 10.0f;
        btnOrder.layer.borderColor = [UIColor whiteColor].CGColor;
        btnOrder.layer.borderWidth = 1.0f;
        
        [btnOrder setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f] forState:UIControlStateNormal];
        [btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnOrder.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [btnOrder.titleLabel setShadowOffset:CGSizeMake(1, 1)];
        [btnOrder setBackgroundColor:[UIColor colorWithRed:1.0f green:0.67f blue:0.21 alpha:1.0f]];

        userLabel = [[UILabel alloc] init];
        NSString *username = _listing[@"username"] ?: @"Unknown";
        
        NSDictionary *usernameAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName: [UIFont systemFontOfSize:12.0f]};
        NSMutableAttributedString *userText = [[NSMutableAttributedString alloc] initWithString:username attributes:usernameAttributes];
        [userText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, [username length])];
        userLabel.attributedText = userText;
        [containerView addSubview:userLabel];
        [self layoutSubviews];
        
        @try{
            if ([_listing[@"user"] objectForKey:@"image"]) {
                if ([_listing[@"user"][@"image"] isKindOfClass:[NSNull class]]) {
                    profileImageView.image = [UIImage imageNamed:@"portrait.png"];
                } else {
                    [profileImageView sd_setImageWithURL:[NSURL URLWithString:_listing[@"user"][@"image"][@"url"]]];
                }
            } else {
                if (![_listing objectForKey:@"owner_image_url"] || [_listing[@"owner_image_url"] isKindOfClass:[NSNull class]]) {
                    profileImageView.image = [UIImage imageNamed:@"portrait.png"];
                } else {
                    [profileImageView sd_setImageWithURL:[NSURL URLWithString:_listing[@"owner_image_url"]]];
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
                            location = [NSString stringWithFormat:@" %@, %@", placemark.addressDictionary[(NSString*)kABPersonAddressCityKey], placemark.addressDictionary[(NSString*)kABPersonAddressStateKey]];
                        
                        /*NSArray *locations = placemark.addressDictionary[@"FormattedAddressLines"];
                        int lower_range = (locations.count > 2 ? 1: 0);
                        int high_range = (locations.count > 2 ? 3 : (int)locations.count);

                        for(int i = lower_range; i < high_range; i++){
                            NSString *loc = locations[i];
                            if( [location isEqualToString:@""] )
                                [location appendString:loc];
                            else
                                [location appendFormat:@", %@", loc];
                        }*/
                        
                        [userText appendAttributedString:[[NSAttributedString alloc] initWithString:location attributes:usernameAttributes]];
                        userLabel.attributedText = userText;
                        
                    }@catch(NSException *e){
                        
                    }
                    
                }
            }];
            
            NSMutableString *category = [[NSMutableString alloc] init];
            
            if( _listing[@"category"] && ![_listing[@"category"] isKindOfClass:[NSNull class]] )
                [category appendString: _listing[@"category"]];
            
            if( _listing[@"sub_category"] && ![_listing[@"sub_category"] isKindOfClass:[NSNull class]] )
                [category appendFormat:@" > %@", _listing[@"sub_category"]];
            
            categoryLabel.text = category;
            
            if( listing[@"main_image"] && ![listing[@"main_image"] isKindOfClass:[NSNull class]] ){
                if( [listing[@"main_image"] isKindOfClass:[NSString class]] && listing[@"main_image"] ){
                    [mainImageIndicator startAnimating];
                    [[SDImageCache sharedImageCache] queryDiskCacheForKey:listing[@"main_image"] done:^(UIImage *image, SDImageCacheType cacheType) {
                        if( image != nil){
                            listingImageView.image = image;
                            [mainImageIndicator stopAnimating];
                        } else {
                            [SDWebImageDownloader.sharedDownloader downloadImageWithURL: [NSURL URLWithString:listing[@"main_image"]] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [mainImageIndicator stopAnimating];
                                    if( error == nil ){
                                        listingImageView.image = image;
                                        [[SDImageCache sharedImageCache] storeImage:image forKey:listing[@"main_image"]];
                                    } else {
                                        listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
                                        [[SDImageCache sharedImageCache] storeImage:listingImageView.image forKey:listing[@"main_image"]];
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
           
            
            if( listing[@"baseprice"] )
                [btnOrder setTitle:[NSString stringWithFormat:@"ORDER $%d", (int)[listing[@"baseprice"] integerValue]]  forState:UIControlStateNormal];
            else
                [btnOrder setTitle:@"ORDER $20" forState:UIControlStateNormal];
        
        }@catch(NSException *e){
            
            profileImageView.image = [UIImage imageNamed:@"portrait.png"];
            listingImageView.image = [UIImage imageNamed:@"placeholder_image.png"];
            [btnOrder setTitle:@"ORDER $20" forState:UIControlStateNormal];
            
            NSLog(@"Exception: %@", e.description);
        }
        
        btnOrder.userInteractionEnabled = NO;
        
        [containerView addSubview:profileImageView];
        [containerView addSubview:titleLabel];
        [containerView addSubview:listingImageView];
        [containerView addSubview:categoryLabel];
        [containerView addSubview:btnOrder];
        
        
        [containerView addSubview:mainImageIndicator];
        [self.contentView addSubview:containerView];

    }
    
    return self;
}

-(void) layoutSubviews {
    
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    [containerView setFrame:CGRectMake(10, 8, width - 20, height - 16)];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:containerView.bounds];
    containerView.layer.shadowPath = shadowPath.CGPath;
    
    [titleLabel setFrame:CGRectMake(60, 5, width - 90, 35)];
    [userLabel setFrame:CGRectMake(60, 42, width - 90, 14)];
    [listingImageView setFrame:CGRectMake(15, 64, width-45, height - 106)];
    mainImageIndicator.center = listingImageView.center;
    [btnOrder setFrame:CGRectMake(width - 120, height - 70, 80, 20)];
    [categoryLabel setFrame:CGRectMake(15, height - 42, width-25, 26)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
