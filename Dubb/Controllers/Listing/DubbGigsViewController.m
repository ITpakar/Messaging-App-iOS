//
//  DubbGigsViewController.m
//  Dubb
//
//  Created by Oleg K on 4/21/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbGigsViewController.h"
#import "SVPullToRefresh.h"
#import "DubbListingCell.h"

@interface DubbGigsViewController (){
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *gigsTableView;
    NSMutableArray *listings;
    NSInteger currentListingPage;
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
        currentListingPage = 1;
        [self.backend getAllListings:self.keyword Page:[NSString stringWithFormat:@"%d", currentListingPage] CompletionHandler:^(NSDictionary *result) {
            [self hideProgress];
            [gigsTableView.pullToRefreshView stopAnimating];
            if( ![result[@"error"] boolValue] ){
                listings = [NSMutableArray arrayWithArray:result[@"response"][@"hits"][@"hit"]];
                [gigsTableView reloadData];
                
                currentListingPage++;
            }
        }];
        
    } else {

        [self.backend getAllListings:self.keyword Page:[NSString stringWithFormat:@"%d", currentListingPage] CompletionHandler:^(NSDictionary *result) {
            [gigsTableView.infiniteScrollingView stopAnimating];
            if( ![result[@"error"] boolValue] ){
                NSArray *results = result[@"response"][@"hits"][@"hit"];
                if( [results count] > 0 ){
                    [listings addObjectsFromArray:results];
                    currentListingPage++;
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
    return 250.f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"CELL%u", indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( !cell )
        cell = [[DubbListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier listingInfo:listings[indexPath.row][@"fields"]];

    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
