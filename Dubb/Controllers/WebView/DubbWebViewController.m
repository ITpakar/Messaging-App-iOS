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
@property (strong, nonatomic) IBOutlet UITextView *privacyTextView;
@property (strong, nonatomic) IBOutlet UITextView *termsOfServiceTextView;

@end

@implementation DubbWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.titleString;
    if ([self.title isEqualToString:@"Privacy"]) {
        self.privacyTextView.hidden = NO;
    } else {
        self.privacyTextView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
