//
//  DubbServiceAreaViewController.m
//  Dubb
//
//  Created by andikabijaya on 3/26/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "AppDelegate.h"
#import "DubbServiceAreaViewController.h"

NSString *const apiKey = @"AIzaSyBqO1R2q7YGqnEAegFiA4vbHo7oLn8IqV0";

typedef NS_ENUM(NSUInteger, TableViewSection){
    TableViewSectionCurrentLocation,
    TableViewSectionMain,
    TableViewSectionCount
};


@implementation DubbServiceAreaViewController

#pragma mark - LifeCycle Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.localSearchQueries = [NSMutableArray array];
    self.pastSearchWords = [NSMutableArray array];
    self.pastSearchResults = [NSMutableArray array];
    self.searchTextField.delegate = self;
    self.selectedLocation = [[SelectedLocation alloc] init];
    
    [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationUpdated) name:kNotificationDidLocationUpdated object:nil];
    
    [self.localSearchQueries removeAllObjects];
    [self.pastSearchResults removeAllObjects];
    [self.pastSearchWords removeAllObjects];
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDidLocationUpdated object:nil];
    
    
}

#pragma mark - Notification Observer
- (void)userLocationUpdated {
    self.selectedLocation.locationCoordinates = CLLocationCoordinate2DMake([[User currentUser].latitude floatValue], [[User currentUser].longitude floatValue]);
}

#pragma mark - Navigation View Button Events
- (IBAction)saveButtonTapped:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(completedWithRadius:WithLocation:)]) {
        [self.delegate completedWithRadius:self.radiusTextField.text WithLocation:self.selectedLocation];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate
- (IBAction)textFieldDidChange:(id)sender {
    
    NSString *searchWordProtection = [self.searchTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Length: %lu",(unsigned long)searchWordProtection.length);
    
    if (searchWordProtection.length != 0) {
        
        [self runScript];
        
    } else {
        NSLog(@"The searcTextField is empty.");
    }
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    self.substring = [NSString stringWithString:self.searchTextField.text];
    self.substring = [self.substring stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    self.substring = [self.substring stringByReplacingCharactersInRange:range withString:text];
    
    if ([self.substring hasPrefix:@"+"] && self.substring.length >1) {
        self.substring  = [self.substring substringFromIndex:1];
        NSLog(@"This string: %@ had a space at the begining.",self.substring);
    }
    
    
    return YES;
}

#pragma mark - Custom Methods

- (void)initView {
    
    [self createFooterViewForTable];
    
    // Configure a PickerView for selecting a position
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    
    self.radiusTextField.inputAccessoryView = toolbar;
    self.searchTextField.inputAccessoryView = toolbar;
    
    NSMutableArray *radiusItems = [NSMutableArray array];
    for (int i = 5; i <= 100; i += 5) {
        [radiusItems addObject:[NSString stringWithFormat:@"%d", i]];
    }
    [self.radiusTextField setItemList:radiusItems];
    
    [self.radiusContainerView.layer setCornerRadius:10.0f];
    [self.radiusContainerView.layer setBorderColor:[UIColor colorWithRed:0 green:65/255.0f blue:125.0f/255.0f alpha:1.0f].CGColor];
    [self.radiusContainerView.layer setMasksToBounds:YES];
    [self.radiusContainerView.layer setBorderWidth:1.0f];
    
    [self.locationContainerView.layer setCornerRadius:10.0f];
    [self.locationContainerView.layer setBorderColor:[UIColor colorWithRed:0 green:65/255.0f blue:125.0f/255.0f alpha:1.0f].CGColor];
    [self.locationContainerView.layer setBorderWidth:1.0f];
    [self.locationContainerView.layer setMasksToBounds:YES];
    
    if (self.titleString) {
        self.titleLabel.text = self.titleString;
    }
    
}
- (void)runScript{
    
    [self.autoCompleteTimer invalidate];
    self.autoCompleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.65f
                                                              target:self
                                                            selector:@selector(searchAutocompleteLocationsWithSubstring:)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)doneClicked:(UIBarButtonItem*)button {
    [self.view endEditing:YES];
}

- (void)searchAutocompleteLocationsWithSubstring:(NSString *)substring
{
    [self.localSearchQueries removeAllObjects];
    [self.tableView reloadData];
    
    if (![self.pastSearchWords containsObject:self.substring]) {
        [self.pastSearchWords addObject:self.substring];
        NSLog(@"Search: %lu",(unsigned long)self.pastSearchResults.count);
        [self retrieveGooglePlaceInformation:self.substring withCompletion:^(NSArray * results) {
            [self.localSearchQueries addObjectsFromArray:results];
            NSDictionary *searchResult = @{@"keyword":self.substring,@"results":results};
            [self.pastSearchResults addObject:searchResult];
            [self.tableView reloadData ];
            
        }];
        
    }else {
        
        for (NSDictionary *pastResult in self.pastSearchResults) {
            if([[pastResult objectForKey:@"keyword"] isEqualToString:self.substring]){
                [self.localSearchQueries addObjectsFromArray:[pastResult objectForKey:@"results"]];
                [self.tableView reloadData];
            }
        }
    }
}


#pragma mark - Google API Requests


-(void)retrieveGooglePlaceInformation:(NSString *)searchWord withCompletion:(void (^)(NSArray *))complete{
    NSString *searchWordProtection = [searchWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (searchWordProtection.length != 0) {
        
        CLLocation *userLocation = self.locationManager.location;
        NSString *currentLatitude = @(userLocation.coordinate.latitude).stringValue;
        NSString *currentLongitude = @(userLocation.coordinate.longitude).stringValue;
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=500&language=en&key=%@",searchWord,currentLatitude,currentLongitude,apiKey];
        NSLog(@"AutoComplete URL: %@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *results = [jSONresult valueForKey:@"predictions"];
            
            if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
                if (!error){
                    NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                    NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                    complete(@[@"API Error", newError]);
                    return;
                }
                complete(@[@"Actual Error", error]);
                return;
            }else{
                complete(results);
            }
        }];
        
        [task resume];
    }
    
}

-(void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSArray *))complete {
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",place,apiKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"result"];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                complete(@[@"API Error", newError]);
                return;
            }
            complete(@[@"Actual Error", error]);
            return;
        }else{
            complete(results);
        }
    }];
    
    [task resume];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return TableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return self.pastSearchQueries.count;
    switch (section) {
        case TableViewSectionCurrentLocation:
            return 1;
            break;
        case TableViewSectionMain:
            return self.localSearchQueries.count;
            break;
    }
    
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TableViewSectionMain: {
            //this is where it broke
            NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
            NSString *placeID = [searchResult objectForKey:@"place_id"];
            [self.searchTextField resignFirstResponder];
            [self retrieveJSONDetailsAbout:placeID withCompletion:^(NSArray *place) {
                
                
                self.selectedLocation.name = [place valueForKey:@"name"];
                self.selectedLocation.address = [place valueForKey:@"formatted_address"];
                NSString *latitude = [NSString stringWithFormat:@"%@,",[place valueForKey:@"geometry"][@"location"][@"lat"]];
                NSString *longitude = [NSString stringWithFormat:@"%@",[place valueForKey:@"geometry"][@"location"][@"lng"]];
                
                self.selectedLocation.locationCoordinates = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                NSLog(@"Location Info: %@",self.selectedLocation);
                
                [self.searchTextField setText:[NSString stringWithFormat:@"%@",self.selectedLocation.address]];
                
                //[self performSegueWithIdentifier:@"BackToMainSearch" sender:self];
                
                
            }];
        }break;
            
        case TableViewSectionCurrentLocation: {
            
            self.selectedLocation.name = @"Current Location";
            self.selectedLocation.address = @"";
            self.selectedLocation.locationCoordinates = CLLocationCoordinate2DMake(38.910003, -77.015533);
        }break;
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (indexPath.section) {
        case TableViewSectionCurrentLocation: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentLocationCell" forIndexPath:indexPath];
            
        }break;
        case TableViewSectionMain: {
            cell =  [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
            NSDictionary *searchResult = [self.localSearchQueries objectAtIndex:indexPath.row];
            cell.textLabel.text = [searchResult[@"terms"] objectAtIndex:0][@"value"];
            cell.detailTextLabel.text = searchResult[@"description"];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0];
        }break;
        default:
            break;
    }
    return cell;
}


- (void)createFooterViewForTable{
    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 500, 320, 70)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white"]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.frame = CGRectMake(110,10,85,12);
    [footerView addSubview:imageView];
    self.tableView.tableFooterView = footerView;
}


@end
