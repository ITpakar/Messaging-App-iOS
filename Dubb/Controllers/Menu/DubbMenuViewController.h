//
//  DubbMenuViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 16/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbMenuViewController : BaseViewController <RESideMenuDelegate>

-(void) updateSelectedRow : (NSInteger) item;

@end
