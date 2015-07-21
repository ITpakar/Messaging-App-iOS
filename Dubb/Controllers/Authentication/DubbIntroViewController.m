//
//  DubbIntroViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbIntroViewController.h"
#import "AppDelegate.h"

@interface DubbIntroViewController (){
    
    __weak IBOutlet UIPageControl *pageControl;
}

@end

@implementation DubbIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id loggedUser = [defaults objectForKey:@"DubbUser"];
    if( loggedUser ){
        [self showProgress:@"Logging in..."];
        [User initialize: (NSDictionary*)loggedUser];
        [self loginToQuickBlox];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pageControl setCurrentPage:(int) scrollView.contentOffset.x / scrollView.frame.size.width];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
