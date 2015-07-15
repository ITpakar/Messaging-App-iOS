//
//  ListingImageView.h
//  Dubb
//
//  Created by andikabijaya on 7/12/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListingImageView : UIView

@property (nonatomic) BOOL selected;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *recycleBinContainerView;

- (void)showAddPhotoView;
- (void)initValues;

@end
