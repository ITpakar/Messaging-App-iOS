//
//  DubbServiceDescriptionViewController.h
//  Dubb
//
//  Created by andikabijaya on 3/24/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DubbServiceDescriptionViewControllerDelegate <NSObject>
@required
- (void) completedWithDescription:(NSString*)description;
@end

@interface DubbServiceDescriptionViewController : UIViewController

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *placeholderString;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic,strong) id<DubbServiceDescriptionViewControllerDelegate> delegate;
@end

