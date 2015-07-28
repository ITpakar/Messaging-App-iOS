//
//  DubbMyListingsViewController.m
//  Dubb
//
//  Created by andikabijaya on 6/7/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "DubbCreateListingTableViewController.h"
#import "DubbMyListingsViewController.h"
#import "NSDate+Helper.h"
#import <SDWebImage/UIImageView+WebCache.h>

enum DubbListingCellTag {
    kDubbListingCellProfileImageViewTag = 100,
    kDubbListingCellTitleLabelTag,
    kDubbListingCellCategoryLabelTag,
    kDubbListingCellPostedDateLabelTag,
    kDubbListingCellProgressIndicatorImageViewTag
};

@implementation DubbMyListingsViewController
{
    NSArray *listingDetails;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.backend getAllMyListingsWithCompletionHandler:^(NSDictionary *result) {
        
        listingDetails = result[@"response"];
        if (listingDetails.count > 0) {
            
            [self.tableView reloadData];
            
        } else {
            
            self.emptyView.hidden = NO;
            
        }
        
        
    }];

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listingDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DubbMyListingCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kDubbListingCellProfileImageViewTag];
    UIImageView *progressIndicatorImageView = (UIImageView *)[cell viewWithTag:kDubbListingCellProgressIndicatorImageViewTag];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kDubbListingCellTitleLabelTag];
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:kDubbListingCellCategoryLabelTag];
    UILabel *postedDateLabel = (UILabel *)[cell viewWithTag:kDubbListingCellPostedDateLabelTag];
    
    NSDictionary *listingDetail = listingDetails[indexPath.row];
    
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:listingDetail[@"main_image"][@"url"]]];
    titleLabel.text = [NSString stringWithFormat:@"%@%@",[[listingDetail[@"name"] substringToIndex:1] uppercaseString], [listingDetail[@"name"] substringFromIndex:1]];
    categoryLabel.text = [NSString stringWithFormat:@"%@ > %@", listingDetail[@"category"][@"name"], listingDetail[@"subcategory"][@"name"]];
    NSDate *date = [NSDate dateFromString:listingDetail[@"created_at"]];
    postedDateLabel.text = [NSString stringWithFormat:@"Posted: %@", [date stringWithFormat:@"MMMM dd, yyyy"]];
    NSString *imageName = ([listingDetail[@"status"] isEqualToString:@"approved"]) ? @"approved_indicator.png" : @"pending_indicator.png";
    progressIndicatorImageView.image = [UIImage imageNamed:imageName];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *listingDetail = listingDetails[indexPath.row];
    DubbCreateListingTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"listingsController"];
    vc.listingDetail = listingDetail;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)createListingBarTapped:(id)sender {
    
    [self showCreateListingTableViewController];
    
}

@end
