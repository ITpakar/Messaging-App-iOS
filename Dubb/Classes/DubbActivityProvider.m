//
//  QuotifulActivityProvider.m
//  Quotiful
//
//  Created by andikabijaya on 10/20/14.
//  Copyright (c) 2014 SourcePad. All rights reserved.
//

#import "DubbActivityProvider.h"

@implementation DubbActivityProvider

- (id)initWithListingTitle:(NSString *)listingTitle
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        self.listingTitle = listingTitle;
    }
    return self;
}

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    NSString *defaultTextToShare = [NSString stringWithFormat:@"Checkout this listing %@. Download app at http://www.dubb.com/app", self.listingTitle];
    
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return [NSString stringWithFormat:@"Checkout %@ @dubbapp creative freelancer marketplace. Download  http://www.dubb.com/app", self.listingTitle];
    if ( [activityType isEqualToString:UIActivityTypeMail] )
        return @"You can download the app at http://www.dubb.com/app";
    
    return defaultTextToShare;
}
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypeMail]) {
        return [NSString stringWithFormat:@"Checkout this listing %@ On Dubb", self.listingTitle];
    }
    
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end
