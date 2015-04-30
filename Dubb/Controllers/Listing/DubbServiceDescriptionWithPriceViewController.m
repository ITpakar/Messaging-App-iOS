//
//  DubbServiceDescriptionWithPriceViewController.m
//  Dubb
//
//  Created by andikabijaya on 3/24/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "SZTextView.h"
#import "DubbServiceDescriptionWithPriceViewController.h"

@interface DubbServiceDescriptionWithPriceViewController ()
@property (strong, nonatomic) IBOutlet SZTextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextField *priceTextField;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DubbServiceDescriptionWithPriceViewController

#pragma mark - UIViewController Delegates

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

#pragma mark - Navigation View Button Events
- (IBAction)saveButtonTapped:(id)sender {
    

    if (self.currentIndex == -1) {
        [self.addOns addObject:@{@"description":self.descriptionTextView.text, @"price":[self.priceTextField.text substringFromIndex:2], @"sequence":[NSString stringWithFormat:@"%ld", self.addOns.count + 1]}];
    } else {
        [self.addOns setObject:@{@"description":self.descriptionTextView.text, @"price":[self.priceTextField.text substringFromIndex:2], @"sequence":[NSString stringWithFormat:@"%ld", self.currentIndex + 1]} atIndexedSubscript:self.currentIndex];
    }

    
    if ([self.delegate respondsToSelector:@selector(completedWithDescription:WithPrice:)]) {
        [self.delegate completedWithDescription:self.descriptionTextView.text WithPrice:self.priceTextField.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Methods

- (void)initView {
    if (self.titleString) {
        self.titleLabel.text = self.titleString;
        [self.descriptionTextView setPlaceholder:self.placeholderString];
    }
    
    if (self.addOns && self.currentIndex != -1) {
        NSDictionary *addOn = self.addOns[self.currentIndex];
        self.descriptionTextView.text = addOn[@"description"];
        self.priceTextField.text = [NSString stringWithFormat:@"$%@", addOn[@"price"]];
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
