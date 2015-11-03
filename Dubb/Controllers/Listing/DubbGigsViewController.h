//
//  DubbGigsViewController.h
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "BaseViewController.h"

@interface DubbGigsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *keyword;

@end
