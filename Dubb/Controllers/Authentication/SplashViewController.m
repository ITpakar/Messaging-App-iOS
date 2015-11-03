//
//  SplashViewController.m
//  Dubb
//
//  Created by andikabijaya on 10/12/15.
//  Copyright © 2015 dubb.co. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id loggedUser = [defaults objectForKey:@"DubbUser"];
    if( loggedUser ){
        [self showProgress:@"Logging in..."];
        [User initialize: (NSDictionary*)loggedUser];
        [self loginToQuickBlox];
    } else {
        [self performSegueWithIdentifier:@"showIntroViewController" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
