//
//  DubbServiceDescriptionWithPriceViewController.h
//  Dubb
//
//  Created by andikabijaya on 3/24/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DubbServiceDescriptionWithPriceViewControllerDelegate <NSObject>
@required
- (void) completedWithDescription:(NSString*)description WithPrice:(NSString *)price;
@end


@interface DubbServiceDescriptionWithPriceViewController : UIViewController

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *placeholderString;

@property (nonatomic,strong) id<DubbServiceDescriptionWithPriceViewControllerDelegate> delegate;

@end
