//
//  DubbSubCategoryController.h
//  Dubb
//
//  Created by Oleg K on 5/19/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "BaseViewController.h"

@interface DubbSubCategoryController : BaseViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSString *categoryID;

@end
