//
//  DubbMenuViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 16/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbRootViewController.h"

@interface DubbRootViewController ()

@end

@implementation DubbRootViewController

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    self.panGestureEnabled = YES;
    self.parallaxEnabled = NO;
    self.contentViewInLandscapeOffsetCenterX = -100.0f;
    
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.backgroundImage = [UIImage imageNamed:@"menu_bg.png"];    
}


@end
