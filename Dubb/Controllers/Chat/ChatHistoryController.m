//
//  ChatHistoryController.m
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "ChatHistoryController.h"
#import "ChatViewController.h"
#import "SVPullToRefresh.h"

@interface ChatHistoryController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>{
    NSInteger pageNo;
}

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;


@end

@implementation ChatHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    pageNo = 0;
    
    if([User currentUser].chatUser){
        [self showProgress:@"Loading..."];
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
    }
    
    [self initializeTableView];
    

}

-(void) initializeTableView{
    
    [self.dialogsTableView addPullToRefreshWithActionHandler:^{
        pageNo = 0;
        [self reloadChatHistory];
    }];
    
    [self.dialogsTableView addInfiniteScrollingWithActionHandler:^{
        pageNo = [self.dialogs count] / 100;
        [self reloadChatHistory];
    }];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    if( [_dialogs count] > 0 ) [self reloadChatHistory];
}


-(void) reloadChatHistory
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if( pageNo != 0 ) [params setObject:@(self.dialogs.count) forKey:@"skip"];
    
    [QBChat dialogsWithExtendedRequest:params delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    
    cell.tag  = indexPath.row;
    
    QBUUser *recipient = [User currentUser].usersAsDictionary[@(chatDialog.recipientID)];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    UILabel *lblUser = (UILabel*)[cell viewWithTag:101];
    UILabel *lblMessage = (UILabel*)[cell viewWithTag:102];
    UILabel *lblUnreadMsg = (UILabel*)[cell viewWithTag:103];
    
    NSInteger currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger userLastRequestAtTimeInterval   = [[recipient lastRequestAt] timeIntervalSince1970];
    
    // if user didn't do anything last 1 minute
    if((currentTimeInterval - userLastRequestAtTimeInterval) > 60){
        imageView.backgroundColor = [UIColor grayColor];
    } else
        imageView.backgroundColor = [UIColor greenColor];
    
    lblUser.text = recipient.fullName;
    if( chatDialog.lastMessageText ){
        if( chatDialog.lastMessageText.length > 20)
            lblMessage.text = [NSString stringWithFormat:@"%@...", [chatDialog.lastMessageText substringToIndex:20]];
        else
            lblMessage.text = chatDialog.lastMessageText;
    } else
        lblMessage.text = @"";
    
    if( chatDialog.unreadMessagesCount == 0 )
        lblUnreadMsg.hidden = YES;
    else{
        lblUnreadMsg.hidden = NO;
        lblUnreadMsg.text = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    ChatViewController *chatController = (ChatViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"chatController"];
    chatController.dialog = dialog;
    [self.navigationController pushViewController:chatController animated:YES];
    
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(QBResult *)result{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        
        [self.dialogsTableView.pullToRefreshView stopAnimating];
        [self.dialogsTableView.infiniteScrollingView stopAnimating];
        
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;

        if( pageNo == 0 )
            self.dialogs = [dialogs mutableCopy];
        else
            [self.dialogs addObjectsFromArray:dialogs];
        
        QBGeneralResponsePage *pagedRequest = [QBGeneralResponsePage responsePageWithCurrentPage:pageNo perPage:100];
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:pagedRequest successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            
            [User currentUser].chatUsers = users;
            
            [self.dialogsTableView reloadData];
            [self hideProgress];
            
        } errorBlock:nil];
        
    }
}


@end
