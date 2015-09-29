//
//  DubbCategoriesViewController.m
//  Dubb
//
//  Created by Oleg K on 5/13/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbCategoriesViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DubbCategoryCell.h"
#import "DubbSubCategoryController.h"

@interface DubbCategoriesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>{
    
    __weak IBOutlet UICollectionView *categoryCollectionView;
    NSMutableArray *categoryList;
    
}

@end

@implementation DubbCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self showProgress:@""];
    [self.backend getAllCategories:^(NSDictionary *result) {
        [self hideProgress];
        if( ![result[@"error"] boolValue] ){
            categoryList = [NSMutableArray arrayWithArray:result[@"response"]];
            NSLog(@"%@", categoryList);
            [categoryCollectionView reloadData];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.navigationController.view.bounds.size.width/2.0f, self.navigationController.view.bounds.size.width/2.0f);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [categoryList count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DubbCategoryCell* cell = (DubbCategoryCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
    //if( cell.categoryData == nil ){
        [cell setupCell:categoryList[indexPath.row]];
    //}
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DubbSubCategoryController *subCategoryController = (DubbSubCategoryController*)[self.storyboard instantiateViewControllerWithIdentifier:@"subCategoryController"];
    subCategoryController.categoryID = categoryList[indexPath.row][@"id"];
    [self.navigationController pushViewController:subCategoryController animated:YES];
    
    
    // Track event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Browsing"     // Event category (required)
                                                          action:@"Category Filtering"  // Event action (required)
                                                           label:@"Filtering by category"          // Event label
                                                           value:nil] build]];    // Event value
    

}


- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
