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
#import "AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DubbGigsViewController (){
    DubbListingCell *currentCell;
    MPMoviePlayerController *videoController;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *gigsTableView;
    NSMutableArray *listings;
    AFHTTPRequestOperation *operation;
    
    BOOL isDownloading;
}

@end

@implementation DubbGigsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    titleLabel.text = _keyword;
    [self setupListingTableView];
   
    videoController = [[MPMoviePlayerController alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playButtonTapped:) name:kNotificationDidTapPlayButton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:videoController];
    isDownloading = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [videoController stop];
    [videoController.view removeFromSuperview];
    videoController = nil;
    
    if(operation) {
        [operation cancel];
        operation = nil;
    }

    if (currentCell) {
        [currentCell setDownloadProgress:0];
        currentCell = nil;
    }
    isDownloading = NO;
}


#pragma mark - Notification Observers
- (void)playButtonTapped:(NSNotification *)notification {
    
    NSLog(@"play button tapped");
    if (isDownloading) {
        NSLog(@"is downloading...");
        return;
    }
    DubbListingCell *cell = notification.userInfo[@"cell"];
    currentCell = cell;
    [self downloadVideo:[self prepareVideoUrl:cell.listing[@"main_video"]]];
    
}
- (void)videoPlayBackDidFinish:(NSNotification *)notification {
    
    // Stop the video player and remove it from view
    [videoController stop];
    [videoController.view removeFromSuperview];
    
    NSLog(@"Finished playback");
    
}
- (void)downloadVideo:(NSURL *)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[url pathComponents].lastObject];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
//    if (fileExists) {
//        if (currentCell) {
//            videoController.contentURL = [NSURL fileURLWithPath:path];
//            videoController.view.frame = CGRectMake(8, 0, sWidth - 16, 191.0f);
//            [currentCell.contentView addSubview:videoController.view];
//            [videoController play];
//            [currentCell setDownloadProgress:0];
//            currentCell = nil;
//        }
//    } else {
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (currentCell) {
            videoController = [[MPMoviePlayerController alloc] init];
            videoController.contentURL = [NSURL fileURLWithPath:path];
            videoController.view.frame = CGRectMake(8, 0, sWidth - 16, 191.0f);
            [currentCell.contentView addSubview:videoController.view];
            [videoController play];
            [currentCell setDownloadProgress:0];
            currentCell = nil;
            isDownloading = NO;
        }
        NSLog(@"Successfully downloaded file to %@", path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
            [alert show];
        }
        isDownloading = NO;
    }];
    
    [operation start];
    isDownloading = YES;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        NSLog(@"status %f",progress);
        if (currentCell) {
            
            [currentCell setDownloadProgress:progress];
        } else {
            
        }
        
        // self.progressView.progress = progress;
        
    }];
//    }
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
        [self showProgress:@"loading gigs..."];
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
    return 262.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = listings[indexPath.row];
    UITableViewCell *cell;
    NSString *cellIdentifier = item[@"id"];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if( !cell ){
        cell = (DubbListingCell *)[[[NSBundle mainBundle] loadNibNamed:@"DubbListingCell" owner:self options:nil] objectAtIndex:0];
        [(DubbListingCell *)cell initWithListingInfo:item[@"fields"]];
    }

//    if( !cell ) {
//        cell = [[DubbListingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier listingInfo:item[@"fields"]];
//    }

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
    [self.navigationController popViewControllerAnimated:NO];
    //[self.navigationController setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]] animated:NO];
}

- (IBAction)onCategory:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"categoriesController"] animated:YES];
}


@end
