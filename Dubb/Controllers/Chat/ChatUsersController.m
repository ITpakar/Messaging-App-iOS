//
//  ChatUsersController.m
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "ChatUsersController.h"
#import "UsersPaginator.h"
#import "ChatViewController.h"
#import "SVPullToRefresh.h"

@interface ChatUsersController () <UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate, QBActionStatusDelegate>

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, weak) IBOutlet UITableView *usersTableView;
@property (nonatomic, strong) UsersPaginator *paginator;

@end

@implementation ChatUsersController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.users = [NSMutableArray array];
    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];
    
    [self initializeTableView];

}

-(void) initializeTableView{
    
    [self.usersTableView addPullToRefreshWithActionHandler:^{
        [self.paginator fetchFirstPage];
    }];
    
    [self.usersTableView addInfiniteScrollingWithActionHandler:^{
        if(![self.paginator reachedLastPage]){
            // fetch next page of results
            [self fetchNextPage];
        } else
            [self.usersTableView.infiniteScrollingView stopAnimating];
    }];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    if( [User currentUser].chatUser == nil ) return;
    
    [self showProgress:@"Loading..."];
    [self.paginator fetchFirstPage];
}


- (void)fetchNextPage
{
    [self.paginator fetchNextPage];
    [self showProgress:@"Loading more users..."];
}



#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    QBUUser *user = (QBUUser *)self.users[indexPath.row];
    cell.tag = indexPath.row;
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    UILabel *lblUser = (UILabel*)[cell viewWithTag:101];
    
    NSInteger currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger userLastRequestAtTimeInterval   = [[user lastRequestAt] timeIntervalSince1970];
    
    // if user didn't do anything last 1 minute
    if((currentTimeInterval - userLastRequestAtTimeInterval) > 60){
        imageView.backgroundColor = [UIColor grayColor];
    } else
        imageView.backgroundColor = [UIColor greenColor];
    
    lblUser.text = user.fullName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QBUUser *user = (QBUUser *)self.users[indexPath.row];
    
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.occupantIDs = @[@(user.ID)];
    chatDialog.type = QBChatDialogTypePrivate;
    [QBChat createDialog:chatDialog delegate:self];
    
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result{
    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        // dialog created
        
        QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
        
        ChatViewController *chatController = (ChatViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"chatController"];
        chatController.dialog = dialogRes.dialog;
        [self.navigationController pushViewController:chatController animated:YES];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:[[result errors] componentsJoinedByString:@","]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


#pragma mark
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{

    [self hideProgress];
    [self.usersTableView.pullToRefreshView stopAnimating];
    [self.usersTableView.infiniteScrollingView stopAnimating];
    
    // reload table with users
    NSInteger quickbloxID = [[User currentUser].quickbloxID integerValue];
    NSInteger user_cnt = self.users.count , i;
    
    for(QBUUser *user in results){
        
        if( user.ID == quickbloxID) continue;
        for(i = 0; i < user_cnt; i++){
            if(((QBUUser*)self.users[i]).ID == user.ID ) break;
        }
        
        if( i >= user_cnt )
            [self.users addObject:user];
        else
            [self.users replaceObjectAtIndex:i withObject:user];
    }
    [self.usersTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
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
