//
//  CALayer+XibConfiguration.h
//  Dubb
//
//  Created by andikabijaya on 6/12/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;
@property(nonatomic, assign) UIColor* shadowUIColor;
@end