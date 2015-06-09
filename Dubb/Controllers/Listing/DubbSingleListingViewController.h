//
//  DubbSingleListingViewController.h
//  Dubb
//
//  Created by andikabijaya on 5/8/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"
@interface DubbSingleListingViewController : BaseViewController <KASlideShowDelegate>

@property (weak, nonatomic) NSString *listingID;
- (void)flagButtonTapped;
@end
