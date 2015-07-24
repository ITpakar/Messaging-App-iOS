//
//  DubbWebViewController.m
//  Dubb
//
//  Created by andikabijaya on 7/24/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbWebViewController.h"

@interface DubbWebViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DubbWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.titleString;
    
    NSURL *url;
    if ([self.title isEqualToString:@"Terms of Service"]) {
        url = [NSURL URLWithString:@"http://dubb.com/terms.php"];
    } else {
        url = [NSURL URLWithString:@"http://dubb.com/privacy.php"];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeButtonTapped:(id)sender {
    if ([self.titleString isEqualToString:@"Terms of Service"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.sideMenuViewController presentLeftMenuViewController];
    }
    
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
