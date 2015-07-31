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
    [params setObject:@"last_message_date_sent" forKey:@"sort_desc"];
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
    UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:104];
    
    NSInteger currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger userLastRequestAtTimeInterval   = [[recipient lastRequestAt] timeIntervalSince1970];
    
    // if user didn't do anything last 1 minute
    if((currentTimeInterval - userLastRequestAtTimeInterval) > 70){
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
    
    UIColor *highlightColor = [UIColor colorWithRed:69.0f/255.0f green:140/255.0f blue:204/255.0f alpha:1.0f];
    if( chatDialog.unreadMessagesCount == 0 ) {
        cell.backgroundColor = [UIColor whiteColor];
        lblUnreadMsg.hidden = YES;
    }
    else{
        lblUnreadMsg.hidden = NO;
        cell.backgroundColor = highlightColor;
        lblUnreadMsg.text = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
    }
    
    profileImageView.image = [UIImage imageNamed:@"portrait.png"];
    [QBRequest TDownloadFileWithBlobID:recipient.blobID successBlock:^(QBResponse *response, NSData *fileData) {
        UIImage *image = [UIImage imageWithData:fileData];
        profileImageView.image = image;
        
    } statusBlock:nil errorBlock:^(QBResponse *response) {
        profileImageView.image = [UIImage imageNamed:@"portrait.png"];
    }];
    
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
