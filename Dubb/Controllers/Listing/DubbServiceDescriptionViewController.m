//
//  DubbServiceDescriptionViewController.m
//  Dubb
//
//  Created by andikabijaya on 3/24/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "SZTextView.h"
#import "DubbServiceDescriptionViewController.h"

@interface DubbServiceDescriptionViewController ()
@property (strong, nonatomic) IBOutlet SZTextView *descriptionTextView;

@end

@implementation DubbServiceDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self initView];
    // Do any additional setup after loading the view.
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
    
    if ([self.delegate respondsToSelector:@selector(completedWithDescription:)]) {
        [self.delegate completedWithDescription:self.descriptionTextView.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Methods

- (void)initView {
    
    self.navigationItem.title = self.titleString;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.descriptionTextView setPlaceholder:self.placeholderString];
    if (![self.descriptionString isEqualToString:@"What area is this service for?"] && ![self.descriptionString isEqualToString:@"Add tags separated by commas."]) {
        self.descriptionTextView.text = self.descriptionString;
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
