//
//  DubbMenuViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 16/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbMenuViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AppDelegate.h"

@interface DubbMenuViewController (){
    NSArray *menus;
    NSString *selectedMenu;
    NSString *unreadMessageCount;
    
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UILabel *lblUserName;    
    __weak IBOutlet UIImageView *bannerImageView;
    __weak IBOutlet UITableView *menuTable;
}

@end

#define kTagMarkView 1000
#define kTagIconView 1001
#define kTagMenuItemView 1002

@implementation DubbMenuViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.sideMenuViewController.delegate = self;
    
    menus = [[NSArray alloc] initWithObjects:@"Listings", @"Chat",  @"Logout", nil ];
    selectedMenu = @"Listings";
    
    [self showProfile];
    
}

-(void) showProfile
{
    lblUserName.text = [NSString stringWithFormat:@"%@ %@", [[User currentUser].firstName capitalizedString], [[User currentUser].lastName capitalizedString]];
    profileImageView.image =[User currentUser].profileImage;
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [menus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"menuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIView *markView = [cell viewWithTag:kTagMarkView];
    UILabel *lblMenu = (UILabel*)[cell viewWithTag:kTagMenuItemView];
    
    if( [menus[indexPath.row] isEqualToString:selectedMenu] ){
        markView.hidden = NO;
        cell.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
    } else {
        markView.hidden = YES;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    
    lblMenu.text = menus[indexPath.row];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if( [selectedMenu isEqualToString:menus[indexPath.row]] ) return;
    
    selectedMenu = menus[indexPath.row];
    UINavigationController *contentVC = (UINavigationController*)self.sideMenuViewController.contentViewController;
    [tableView reloadData];
    
    switch (indexPath.row) {
        case 0:
            [contentVC setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"listingsController"]] animated:NO];
            break;
        case 1:
            [contentVC setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"chatNavController"]] animated:NO];
            break;
            
        case 2: {
            
            [[GPPSignIn sharedInstance] signOut];
            [FBSession.activeSession closeAndClearTokenInformation];
            
            if([[QBChat instance] isLoggedIn]){
                [[ChatService instance] logout];
            }
            
            UIViewController *mainController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainController"];
            ((AppDelegate*)[[UIApplication sharedApplication] delegate]).window.rootViewController = mainController;
        }
           return;
        default:
            break;
    }
    
    [self.sideMenuViewController hideMenuViewController];
}

-(void) updateSelectedRow : (NSInteger) item
{
    selectedMenu = menus[item];
    [menuTable reloadData];
}


@end
