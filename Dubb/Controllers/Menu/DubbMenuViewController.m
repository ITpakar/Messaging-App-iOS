//
//  DubbMenuViewController.h
//  Dubb
//
//  Created by Oleg Koshkin on 16/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DubbMenuViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AppDelegate.h"
#import "UserVoice.h"
#import "DubbSalesOrdersViewController.h"
#import "DubbMyListingsViewController.h"
#import "DubbWebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DubbMenuViewController () <UVDelegate>{
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
#define menus @[@"HOME", @"SALES", @"MY LISTINGS", @"ORDERS", @"PROFILE", @"SUPPORT", @"RECENT MESSAGES", @"ABOUT"]
#define menuIcons @[@"home_menu_button.png", @"sales_menu_button.png", @"mylistings_menu_button.png", @"orders_menu_button.png", @"profile_menu_button.png", @"support_menu_button.png", @"inbox_menu_button.png", @"about_menu_button.png"]
@implementation DubbMenuViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.sideMenuViewController.delegate = self;
    selectedMenu = @"HOME";
    
//    if( [[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""] )
//        menus[4] = @"Login";
    
    [self showProfile];
    
}

-(void) showProfile
{
    lblUserName.text = [NSString stringWithFormat:@"%@ %@", [[User currentUser].firstName capitalizedString], [[User currentUser].lastName capitalizedString]];
    
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
    UIImageView *iconImageView = (UIImageView *)[cell viewWithTag:kTagIconView];
    
    if( [menus[indexPath.row] isEqualToString:selectedMenu] ){
        markView.hidden = NO;
        cell.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
    } else {
        markView.hidden = YES;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    
    lblMenu.text = menus[indexPath.row];
    iconImageView.image = [UIImage imageNamed:menuIcons[indexPath.row]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if( [selectedMenu isEqualToString:menus[indexPath.row]] ) return;
    
    selectedMenu = menus[indexPath.row];
    UINavigationController *contentVC = (UINavigationController*)self.sideMenuViewController.contentViewController;
    UIViewController *vc;
    [tableView reloadData];
    
    Boolean isAnonymous = [[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""];
    switch (indexPath.row) {
        case 0:
            [contentVC setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]] animated:NO];
            break;
            
        case 1:
            if (isAnonymous) {
                
                [self showLoginView];
                
            } else {
                
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbSalesOrdersViewController"];
                ((DubbSalesOrdersViewController *)vc).userType = @"seller";
                [contentVC setViewControllers:@[vc] animated:NO];
                
            }

            break;
        
        case 2:
            if (isAnonymous) {
                
                [self showLoginView];
                
            } else {
                
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbMyListingsViewController"];
                [contentVC setViewControllers:@[vc] animated:NO];
                
            }
            
            break;
            
        case 3:
            if (isAnonymous) {
                
                [self showLoginView];
                
            } else {
                
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbSalesOrdersViewController"];
                ((DubbSalesOrdersViewController *)vc).userType = @"buyer";
                [contentVC setViewControllers:@[vc] animated:NO];
            
            }
            break;
            
        case 4:
            if (isAnonymous) {
                
                [self showLoginView];
                
            } else {
                
                [contentVC setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"DubbProfileViewController"]] animated:NO];
                
            }
            break;
            
        case 5:
            [UserVoice presentUserVoiceInterfaceForParentViewController:self];
            [UserVoice setDelegate:self];
            break;
            
        case 6:
            if (isAnonymous) {
                
                [self showLoginView];
                
            } else {
                
                if( [User currentUser].chatUser == nil ) return;
                [contentVC setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"ChatHistoryController"]] animated:NO];
                
            }
            break;
        case 7:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DubbAboutViewController"];
            [contentVC setViewControllers:@[vc] animated:NO];
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
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    
    if ([[NSString stringWithFormat:@"%@", [User currentUser].userID] isEqualToString:@""]) {
        
        return;
        
    }
    
    [self.backend getUser:[User currentUser].userID CompletionHandler:^(NSDictionary *result) {
        
        if (result) {
            
            NSDictionary *userInfo = result[@"response"];
            if (![userInfo[@"image"] isKindOfClass:[NSNull class]]) {
                [profileImageView sd_setImageWithURL:[NSURL URLWithString:userInfo[@"image"][@"url"]]];
            }
            
        }
        
    }];
}


#pragma mark - UVDelegate methods

- (void)userVoiceWasDismissed {
    
    UINavigationController *contentVC = (UINavigationController*)self.sideMenuViewController.contentViewController;
    [contentVC setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]] animated:NO];
    
    [self.sideMenuViewController hideMenuViewController];
    
}

@end
