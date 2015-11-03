//
//  AboutViewController.m
//  Dubb
//
//  Created by andikabijaya on 7/24/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "DubbWebViewController.h"
#import "DubbAboutViewController.h"

@interface DubbAboutViewController ()

@end

@implementation DubbAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)termsOfServiceButtonTapped:(id)sender {
    DubbWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbWebViewController"];
    vc.titleString = @"Terms of Service";
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)privacyButtonTapped:(id)sender {
    DubbWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbWebViewController"];
    vc.titleString = @"Privacy";
    [self presentViewController:vc animated:YES completion:nil];
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
