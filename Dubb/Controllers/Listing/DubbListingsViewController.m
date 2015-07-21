//
//  DubbListingsViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 13/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbListingsViewController.h"
#import "DubbListingCell.h"

#import "DubbGigsViewController.h"

#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import "SVPullToRefresh.h"
#import "DubbCategoriesViewController.h"
#import "DubbSingleListingViewController.h"

@interface DubbListingsViewController () {
    
    __weak IBOutlet UIButton *btnMenuBar;
    __weak IBOutlet UIButton *btnRightMenuBar;
    
    __weak IBOutlet UITextField *searchBar;
    __weak IBOutlet NSLayoutConstraint *searchBarConstraint;
    __weak IBOutlet NSLayoutConstraint *searchBarTopConstraint;
    __weak IBOutlet NSLayoutConstraint *searchBarLeftConstraint;
    __weak IBOutlet NSLayoutConstraint *searchContainerViewConstraint;
    
    __weak IBOutlet UILabel *titleLabel;   
    
    IBOutlet UILabel *nameLabel;
    IBOutlet UIView *shadowView;
    IBOutlet UIView *introductionView;
    __weak IBOutlet UITextField *locationSearchBar;
    
    UIView *overlayView;
    UITapGestureRecognizer *tapGestureRecognizer;
    
    __weak IBOutlet UITableView *listingsTableView;
    UITableView *searchResultTableView;
    UITableView *locationTableView;
    
    NSMutableArray *suggestionLists;
    NSMutableArray *locationLists;
    NSString *suggestionKeyword;
    NSString *locationKeyword;
    
    CLGeocoder* geocoder;
    
    NSMutableDictionary *selectedLocation;
    
    NSMutableArray *listings;
    NSInteger currentListingPage;
}

@end

@implementation DubbListingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    nameLabel.text =  [NSString stringWithFormat:@"Dear %@,", [User currentUser].firstName];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SHOWN_INTRODUCTION"]) {
        introductionView.hidden = NO;
        shadowView.hidden = NO;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SHOWN_INTRODUCTION"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        shadowView.hidden = YES;
        introductionView.hidden = YES;
        
    }
    [self setupSearch];
    [self setupListingTableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark - SearchBar

//Initialize UIs for search
-(void) setupSearch{
    
    self.definesPresentationContext = YES;
 
    overlayView = [[UIView alloc] init];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
    [overlayView addGestureRecognizer:tapGestureRecognizer];
    
    suggestionLists = [[NSMutableArray alloc] init];
    searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, self.view.bounds.size.width, self.view.bounds.size.height - 140)];
    searchResultTableView.delegate = self;
    searchResultTableView.dataSource = self;
    
    locationLists = [[NSMutableArray alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, self.view.bounds.size.width, self.view.bounds.size.height - 140)];
    locationTableView.delegate = self;
    locationTableView.dataSource = self;
    
    searchBar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:searchBar.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    
    [searchBar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [locationSearchBar addTarget:self action:@selector(locationFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void) setupListingTableView{
    [listingsTableView addPullToRefreshWithActionHandler:^{
        [self loadListings : YES];
    }];
    
    [listingsTableView addInfiniteScrollingWithActionHandler:^{
        [self loadListings : NO];
    }];
    
    listings = [NSMutableArray new];
    [self loadListings:YES];
}


//Remove search results and overlay view
-(void) cancelSearch{
    [searchBar endEditing:YES];
}

-(void) cancelSearching{
    [suggestionLists removeAllObjects];
    if( searchResultTableView.superview)
        [searchResultTableView removeFromSuperview];
    if( locationTableView.superview)
        [locationTableView removeFromSuperview];
}

#pragma mark SearchBar Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if(locationSearchBar == textField){
        [self.view addSubview:locationTableView];
        return YES;
    }
    
    if( [locationSearchBar.text isEqualToString:@""] ) locationSearchBar.text = @"Current Location";
    if( locationTableView.superview )
        [locationTableView removeFromSuperview];
    
    if( ![searchBar.text isEqualToString:@""] ) return YES;
    
    searchBarConstraint.constant = - btnRightMenuBar.bounds.size.width;
    searchBarTopConstraint.constant = 60;
    searchBarLeftConstraint.constant = -30.0f;
    searchContainerViewConstraint.constant = 140;
    
    [overlayView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    [self.view addSubview:overlayView];
    
    [UIView animateWithDuration:0.3f animations:^{
        titleLabel.hidden = NO;
        [self.view layoutIfNeeded];
        [btnRightMenuBar setSelected:YES];
        [btnRightMenuBar setImage:[UIImage imageNamed:@"btn_search.png"] forState:UIControlStateNormal];
        [overlayView setFrame:CGRectMake(0, 140, self.view.bounds.size.width, self.view.bounds.size.height - 140)];
    } completion:^(BOOL finished) {
        
        overlayView.alpha = 1.0f;
    }];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if( locationSearchBar == textField ){
        return YES;
    }

    if( ![searchBar.text isEqualToString:@""] || locationTableView.superview != nil ) return YES;

    searchBarConstraint.constant = 12;
    searchBarLeftConstraint.constant = 12;
    searchBarTopConstraint.constant = 25;
    searchContainerViewConstraint.constant = 64;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
        [overlayView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
        overlayView.alpha = 0.0;
        titleLabel.hidden = YES;
        [btnRightMenuBar setSelected:NO];
        [btnRightMenuBar setImage:[UIImage imageNamed:@"btn_category.png"] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [overlayView removeFromSuperview];
        overlayView.alpha = 1.0f;
    }];
    
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if( [searchBar.text isEqualToString:@""] ) {
        [searchBar becomeFirstResponder];
    } else {
        DubbGigsViewController *gigsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"gigsSearchResultVC"];
        gigsVC.keyword = searchBar.text;
        
        [self.navigationController pushViewController:gigsVC animated:YES];
    }
    return YES;
}

- (IBAction)clearSearchText:(id)sender {
    searchBar.text = @"";
}

- (IBAction)clearLocationText:(id)sender {
    locationSearchBar.text = @"";
}


#pragma mark - Search Listings
- (void) textFieldDidChange: (id) sender{
    
    NSString *searchText = searchBar.text;
    
    if( ![searchText isEqualToString:@""] ){
        if( searchResultTableView.superview == nil ){
            [self.view insertSubview:searchResultTableView aboveSubview:overlayView];
        }
        
        //Load suggestion List with api
        suggestionKeyword = searchText;
        [searchResultTableView reloadData];
        
        [self performSelector:@selector(updateSuggestions) withObject:nil afterDelay:0.25f];
        
    } else if( searchResultTableView.superview != nil ){
        [self cancelSearching];
    }
}


-(void) updateSuggestions{
    if( ![suggestionKeyword isEqualToString:@""] && [searchBar.text isEqualToString:suggestionKeyword] && [[self.navigationController visibleViewController] isKindOfClass:[DubbListingsViewController class]] ){
        
        [self.backend getSuggestionList:suggestionKeyword CompletionHandler:^(NSDictionary *result) {
            suggestionLists = [[NSMutableArray alloc] init];
            for(NSDictionary* suggestion in result[@"response"]){
                [suggestionLists addObject:suggestion[@"suggestion"]];
            }
            [searchResultTableView reloadData];
        }];
    }
}


#pragma mark - Search Location
- (void) locationFieldDidChange: (id) sender{
    
    NSString *searchText = locationSearchBar.text;
    if( [searchText isEqualToString:@"Current Locatio"] ){
        searchText = @"";
        locationSearchBar.text = @"";
    }

    if( ![searchText isEqualToString:@""] && ![searchText isEqualToString:@"Current Location"] ){
        locationKeyword = searchText;
        [self performSelector:@selector(updateLocations) withObject:nil afterDelay:0.25f];
    } else {
        locationKeyword = @"";
    }
}

-(void) updateLocations{
    if( ![locationKeyword isEqualToString:@""] && [locationSearchBar.text isEqualToString:locationKeyword] ){
        
        [geocoder geocodeAddressString:locationKeyword  completionHandler: ^ (NSArray  *placemarks, NSError *error) {
            [locationLists removeAllObjects];
            for(CLPlacemark *placemark in placemarks) {

                NSMutableDictionary *location = [NSMutableDictionary dictionaryWithDictionary:placemark.addressDictionary];
                [location setObject:@(placemark.location.coordinate.latitude) forKey:@"latitude"];
                [location setObject:@(placemark.location.coordinate.longitude) forKey:@"longitude"];
                [locationLists addObject:location];
            }
            
            NSLog(@"Location Lists: %@", locationLists);
            [locationTableView reloadData];
        }];
    }
}

-(NSString*) getFormattedLocation : (NSInteger) row{
    
    NSMutableString *location = [[NSMutableString alloc] init];
    for(NSString *loc in locationLists[row-1][@"FormattedAddressLines"]){
        if( [location isEqualToString:@""] )
            [location appendString:loc];
        else
            [location appendFormat:@", %@", loc];
    }
    
    return location;
}

#pragma mark - 
#pragma mark - Load Listings

-(void) loadListings : (BOOL) refresh{
    
    if( refresh ){
        [self showProgress:@"Load Listing..."];
        currentListingPage = 1;
        [self.backend getAllListings:[NSString stringWithFormat:@"%d", currentListingPage] CompletionHandler:^(NSDictionary *result) {
            [self hideProgress];
            [listingsTableView.pullToRefreshView stopAnimating];
            if( ![result[@"error"] boolValue] ){
                listings = [NSMutableArray arrayWithArray:result[@"response"]];
                [listingsTableView reloadData];
                currentListingPage++;
            }
        }];
        
    } else {

        
        [self.backend getAllListings:[NSString stringWithFormat:@"%d", currentListingPage] CompletionHandler:^(NSDictionary *result) {
            [listingsTableView.infiniteScrollingView stopAnimating];
            if( ![result[@"error"] boolValue] ){
                if( [result[@"response"] count] > 0 ){
                    currentListingPage ++;
                    [listings addObjectsFromArray:result[@"response"]];
                    [listingsTableView reloadData];
                }
            }
        }];
    }
    
}


#pragma mark -
#pragma mark - TableView Delegate

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == searchResultTableView )
        return [suggestionLists count] + 1;
    else if( tableView == locationTableView )
        return [locationLists count] + 1;
    
    return [listings count];
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == searchResultTableView || tableView == locationTableView )
        return 40.f;
    
    return 250.f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if( tableView == searchResultTableView ){
        cell = [self setupSearchResult:indexPath.row];
    } else if (tableView == locationTableView){
        cell = [self setupLocationList:indexPath.row];
    } else {
        NSDictionary *item = listings[indexPath.row];
        NSString *cellIdentifier = [NSString stringWithFormat:@"listing%@", item[@"id"]];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if( !cell ){
            cell = [[DubbListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier listingInfo:item];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == searchResultTableView ){
        DubbGigsViewController *gigsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"gigsSearchResultVC"];
        
        if( indexPath.row < [suggestionLists count] )
            searchBar.text = suggestionLists[indexPath.row];
        
        gigsVC.keyword = searchBar.text;
        [self.navigationController pushViewController:gigsVC animated:YES];
    } else if (tableView == locationTableView ){
        
        if( indexPath.row == 0 )
            locationSearchBar.text = @"Current Location";
        else {
            selectedLocation = [NSMutableDictionary dictionaryWithDictionary:locationLists[indexPath.row-1]];
            locationSearchBar.text = [self getFormattedLocation:indexPath.row];
            [searchBar becomeFirstResponder];
        }
    } else {
        NSDictionary *item = listings[indexPath.row];
        DubbSingleListingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbSingleListingViewController"];
        vc.listingID = item[@"id"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


-(UITableViewCell*) setupSearchResult : (NSInteger) row
{
    static NSString *CellIdentifier = @"newKeywordCell";
    UITableViewCell *cell = [searchResultTableView dequeueReusableCellWithIdentifier:@"newKeywordCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if( row == [suggestionLists count]){
        NSMutableAttributedString * keyword = [[NSMutableAttributedString alloc] initWithString:
                                              [NSString stringWithFormat:@"search listings containing \"%@\"", searchBar.text]];
        
        [keyword addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, keyword.length)];
        [keyword addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(25, searchBar.text.length)];
        
        cell.textLabel.attributedText = keyword;
    }else if( row < [suggestionLists count]){
        NSMutableAttributedString * keyword = [[NSMutableAttributedString alloc] initWithString: suggestionLists[row]];
        
        [keyword addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, keyword.length)];
        
        NSRange searchRange = NSMakeRange(0, keyword.length);
        NSRange foundRange;
        while (searchRange.location < keyword.length) {
            searchRange.length = keyword.length-searchRange.location;
            foundRange = [keyword.string rangeOfString:searchBar.text options:NSCaseInsensitiveSearch range:searchRange];
            if (foundRange.location != NSNotFound) {
                [keyword addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(foundRange.location, searchBar.text.length)];
                searchRange.location = foundRange.location+foundRange.length;
            } else {
                break;
            }
        }
        
        cell.textLabel.attributedText = keyword;
    }
    
    return cell;
}

-(UITableViewCell*) setupLocationList : (NSInteger) row
{
    static NSString *CellIdentifier = @"newLocationCell";
    UITableViewCell *cell = [searchResultTableView dequeueReusableCellWithIdentifier:@"newLocationCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if( row == 0){
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = @"   Current Location";
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = [self getFormattedLocation:row];
        
    }
    
    return cell;
}


#pragma mark - 
#pragma mark - Navigation

-(void) onBack {
    if( searchResultTableView.superview == nil ){
        searchBar.text = @"";
        [self cancelSearch];
    } else {
        searchBar.text = @"";
        [self cancelSearching];
        [self cancelSearch];
    }
}

- (IBAction)onCategoryOrSearch:(id)sender {
    
    if( btnRightMenuBar.selected ){ //Search
        [self textFieldShouldReturn:nil];
    } else { //Category
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"categoriesController"] animated:YES];
    }
    
}
- (IBAction)closeInstructionViewButtonTapped:(id)sender {
    
    shadowView.hidden = YES;
    introductionView.hidden = YES;
    
}

@end
