//
//  DubbGigsViewController.m
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbGigsViewController.h"
#import "DubbSingleListingViewController.h"
#import "SVPullToRefresh.h"
#import "DubbListingCell.h"

@interface DubbGigsViewController (){
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *gigsTableView;
    NSMutableArray *listings;
}

@end

@implementation DubbGigsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    titleLabel.text = _keyword;
    [self setupListingTableView];
   
}

-(void) setupListingTableView{
    [gigsTableView addPullToRefreshWithActionHandler:^{
        [self loadListings : YES];
    }];
    
    [gigsTableView addInfiniteScrollingWithActionHandler:^{
        [self loadListings : NO];
    }];
    
    listings = [NSMutableArray new];
    [self loadListings:YES];
}


-(void) loadListings : (BOOL) refresh{
    
    if( refresh ){
        [self showProgress:@"Load Listing..."];
        [self.backend getAllListings:self.keyword Page:@"0" CompletionHandler:^(NSDictionary *result) {
            [self hideProgress];
            [gigsTableView.pullToRefreshView stopAnimating];
            if( ![result[@"error"] boolValue] && ![result[@"response"] isKindOfClass: [NSNull class]]){
                listings = [NSMutableArray arrayWithArray:result[@"response"][@"hits"][@"hit"]];
                [gigsTableView reloadData];
            }
        }];
        
    } else {

        [self.backend getAllListings:self.keyword Page:[NSString stringWithFormat:@"%lu", (long)listings.count] CompletionHandler:^(NSDictionary *result) {
            [gigsTableView.infiniteScrollingView stopAnimating];
            if( ![result[@"error"] boolValue] ){
                NSArray *results = result[@"response"][@"hits"][@"hit"];
                if( [results count] > 0 ){
                    [listings addObjectsFromArray:results];
                    [gigsTableView reloadData];
                }
            }
        }];
    }
    
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listings count];
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return sWidth + 61.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = listings[indexPath.row];
    UITableViewCell *cell;
    NSString *cellIdentifier = item[@"id"];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( !cell ) {        
        cell = [[DubbListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier listingInfo:item[@"fields"]];
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *item = listings[indexPath.row];
    DubbSingleListingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbSingleListingViewController"];
    vc.listingID = item[@"fields"][@"id"];
    
    [self.navigationController pushViewController:vc animated:YES];

    
}

-(NSDictionary *) convertGigData : (NSDictionary*) item{
    
    NSMutableDictionary* gigItem = [NSMutableDictionary dictionaryWithDictionary:item];
    NSArray *names = [item[@"username"] componentsSeparatedByString:@" "];
    
    if( [names count] > 0 ) [gigItem setObject:@{@"username":names[0]} forKey:@"user"];
    if( item[@"main_image"] ) [gigItem setObject:@{@"url":item[@"main_image"]} forKey:@"mainimage"];
    if( item[@"latlon"] ){
        NSArray* location = [item[@"latlon"] componentsSeparatedByString:@","];
        if(location.count == 2){
            [gigItem setObject:location[0] forKey:@"lat"];
            [gigItem setObject:location[1] forKey:@"longitude"];
        }
    }
    if( item[@"category"] )
        [gigItem setObject:@{@"name":item[@"category"]} forKey:@"category"];

    if( item[@"sub_category"] )
        [gigItem setObject:@{@"name":item[@"sub_category"]} forKey:@"subcategory"];
    
    return gigItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onCategory:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"categoriesController"] animated:YES];
}


@end
