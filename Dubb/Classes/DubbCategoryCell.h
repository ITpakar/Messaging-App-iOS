//
//  DubbCategoryCell.h
//  Dubb
//
//  Created by Oleg K on 5/13/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbCategoryCell : UICollectionViewCell

@property NSDictionary *categoryData;
-(void) setupCell : (NSDictionary*) category;

@end
