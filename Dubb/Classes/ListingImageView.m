//
//  ListingImageView.m
//  Dubb
//
//  Created by andikabijaya on 7/12/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "ListingImageView.h"

@implementation ListingImageView
@synthesize selected = _selected;

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.recycleBinContainerView.hidden = !selected;
}

- (BOOL)selected {
    return _selected;
}

- (void)initValues {
    
    self.selected = NO;
    self.index = 0;
    
}

- (void)showAddPhotoView {
    
    self.addPhotoButton.hidden = NO;
    
}

- (void)showAddVideoView {
    
    self.addVideoButton.hidden = NO;
    
}

- (IBAction)recycleBinTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapRecycleBinButton object:@{@"type":@(self.type), @"index":@(self.index)}];
}
- (IBAction)addPhotoButtonTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapAddPhotoButton object:nil];
}
- (IBAction)addVideoButtonTapped:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapAddVideoButton object:nil];
}
- (IBAction)imageViewTapped:(id)sender {
    self.selected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidTapListingImageView object:@{@"type":@(self.type), @"index":@(self.index)}];
}


@end
