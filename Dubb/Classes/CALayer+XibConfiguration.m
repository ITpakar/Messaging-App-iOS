//
//  CALayer+XibConfiguration.m
//  Dubb
//
//  Created by andikabijaya on 6/12/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setShadowUIColor:(UIColor*)color
{
    self.shadowColor = color.CGColor;
}

-(UIColor*)shadowUIColor
{
    return [UIColor colorWithCGColor:self.shadowColor];
}

@end