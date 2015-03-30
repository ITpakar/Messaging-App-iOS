//
//  ChatViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 13/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "ChatViewController.h"
#import "DubbSenderTableViewCell.h"
#import "DubbReceiverTableViewCell.h"
#import "AsyncImageView.h"
#import "IQKeyboardManager.h"
#import "SVPullToRefresh.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, QBActionStatusDelegate>{
    
    __weak IBOutlet UITableView *messageTableView;
    __weak IBOutlet UILabel *chatTitle;
    __weak IBOutlet UIActivityIndicatorView *recipientProfileActivityIndicator;
    __weak IBOutlet UIImageView *receiverProfileImageView;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet NSLayoutConstraint *bottomConstraint;
    
    __weak IBOutlet UIView *messageContainerView;
    __weak IBOutlet UITextView *messageTextView;
    
    UIImage* recipientImage;
    
    NSMutableArray *messages;
    NSMutableDictionary *sections;
    NSMutableArray *sectionTitles;
    
    NSInteger pageNo;
    NSInteger loadedSections, loadedRows;
    NSDateFormatter *dateFormatter;
    
    BOOL _wasKeyboardManagerEnabled;
}

@end


#define kMinTextViewHeight 55
#define kMaxTextViewHeight 120

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pageNo = 0;
    messages = [NSMutableArray array];
    sections = [NSMutableDictionary dictionary];
    sectionTitles = [NSMutableArray array];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"MMM dd, yyyy EEEE"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:[User currentUser].timeZone*60*60]];
    
    messageContainerView.layer.borderColor = [[UIColor grayColor] CGColor];
    messageContainerView.layer.borderWidth = 1.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    
    [self initializeTableView];
    
}

-(void) initializeTableView{
    
    [messageTableView.pullToRefreshView setTitle:@"Pull to load earlier messages" forState:0];
    [messageTableView.pullToRefreshView setTitle:@"Release to load earlier messages" forState:1];
    
    [messageTableView addPullToRefreshWithActionHandler:^{
        pageNo = 1;
        [self loadMessages];
    }];
    
    /*[messageTableView addInfiniteScrollingWithActionHandler:^{
        pageNo = 0;
        [self loadMessages];
    }];*/
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
    if( recipientImage == nil ){
        [QBRequest userWithID:self.dialog.recipientID successBlock:^(QBResponse *response, QBUUser *user) {
            
            chatTitle.text = user.fullName == nil ? user.login : user.fullName;
            if( user.blobID ){
                
                [recipientProfileActivityIndicator startAnimating];
                [QBRequest TDownloadFileWithBlobID:user.blobID successBlock:^(QBResponse *response, NSData *fileData) {
                    recipientImage = [UIImage imageWithData:fileData];
                    receiverProfileImageView.image = recipientImage;
                    [recipientProfileActivityIndicator stopAnimating];
                    
                    [messageTableView reloadData];
                } statusBlock:nil errorBlock:^(QBResponse *response) {
                    [recipientProfileActivityIndicator stopAnimating];
                    receiverProfileImageView.image = [UIImage imageNamed:@"portrait.png"];
                }];
                
            } else {
                receiverProfileImageView.image = [UIImage imageNamed:@"portrait.png"];
            }
        } errorBlock:^(QBResponse *response) {
            receiverProfileImageView.image = [UIImage imageNamed:@"portrait.png"];
        }];
    }
    
    [self loadMessages];
}

-(void) loadMessages{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"date_sent" forKey:@"sort_desc"];
    [params setObject:@"100" forKey:@"limit"];
    
    if( pageNo != 0 ){
        [params setObject:@(messages.count) forKey:@"skip"];
        loadedSections = sectionTitles.count;
        loadedRows = messages.count;
    }
    
    [self showProgress:@"Loading..."];
    [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:params delegate:self];
}

#pragma mark -
#pragma mark - TableView

-(void)viewDidLayoutSubviews
{
    if ([messageTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [messageTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([messageTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [messageTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = 0;
    for(int i = 0; i < indexPath.section; i++)
        row += [sections[sectionTitles[i]] integerValue];
    
    if( messages.count <= row + indexPath.row ) return 0;
    
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    QBChatAbstractMessage *message = messages[row + indexPath.row];
    textView.text = message.text;
    CGSize size = [textView sizeThatFits:CGSizeMake(self.view.frame.size.width - 135, FLT_MAX)];
    
    return MAX(size.height, 35) + 48;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sections[sectionTitles[section]] integerValue];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, tableView.frame.size.width-40, 26)];
    
    label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    label.text = sectionTitles[section];
    label.font = [UIFont fontWithName:@"Hevetica" size:14.0f];
    label.textColor = [UIColor colorWithRed:56/255.0f green:118/255.0f blue:159/255.0f alpha:1.0f];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOpacity = 0.7f;
    label.layer.shadowRadius = 5.0f;
    label.layer.masksToBounds = NO;
    
    CGSize size = label.bounds.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(size.width * 0.33f, size.height * 0.66f)];
    [path addLineToPoint:CGPointMake(size.width * 0.66f, size.height * 0.66f)];
    [path addLineToPoint:CGPointMake(size.width * 1.15f, size.height * 1.15f)];
    [path addLineToPoint:CGPointMake(size.width * -0.15f, size.height * 1.15f)];
    label.layer.shadowPath = path.CGPath;
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = 0;
    for(int i = 0; i < indexPath.section; i++)
        row += [sections[sectionTitles[i]] integerValue];
    
    if( messages.count <= row + indexPath.row ) return [UITableViewCell new];
    
    DubbChatCell *cell;
    QBChatAbstractMessage *message = messages[row + indexPath.row];
    
    
    if([User currentUser].chatUser.ID == message.senderID) //Sender
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"senderCell" ];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"receiverCell"];
        cell.profileImage = recipientImage;
    }
    
    cell.timestamp = message.datetime;
    cell.message = message.text;
    
    [cell setupCell];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark -
#pragma mark - Keyboard

-(void)textViewDidChange:(UITextView *)textView{
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    
    if(newSize.height > kMinTextViewHeight && newSize.height < kMaxTextViewHeight && (heightConstraint.constant < newSize.height || heightConstraint.constant > newSize.height + 15)){
        heightConstraint.constant = newSize.height + 7;
    }
    
    if( [textView.text isEqualToString:@""] )
        heightConstraint.constant = kMinTextViewHeight;
    
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    bottomConstraint.constant = keyboardBounds.size.height;
    [UIView animateWithDuration:[duration floatValue] animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self scrollBottomOfTableView:NO];
    }];
    
    
    [self performSelector:@selector(scrollBottomOfTableView:) withObject:nil afterDelay:0.25f];
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    bottomConstraint.constant = 0;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) scrollBottomOfTableView : (BOOL)animated
{
    if( messages.count == 0 ) return;
    [messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:-1 + [sections[sectionTitles.lastObject] integerValue]
                                                                inSection: sectionTitles.count - 1]
                            atScrollPosition: UITableViewScrollPositionBottom
                                    animated: animated];
}


-(void) scrollTopOfTableView : (BOOL)animated
{
    if( messages.count == 0 ) return;
    [messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                            atScrollPosition: UITableViewScrollPositionTop
                                    animated: animated];
}

#pragma mark -
#pragma mark Send Message

- (IBAction)onSend:(id)sender {
    heightConstraint.constant = kMinTextViewHeight;
    if( [messageTextView.text isEqualToString:@""] ) return;
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = messageTextView.text;
    messageTextView.text = @"";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    message.recipientID = [self.dialog recipientID];
    message.senderID = [User currentUser].chatUser.ID;
    
    [[ChatService instance] sendMessage:message];
    
    // save message
    [messages addObject:message];
    
    NSDate *now = [NSDate date];
    NSString *localTime = [dateFormatter stringFromDate:now];
    if( sections[localTime] )
        sections[localTime] = @([sections[localTime] integerValue] + 1);
    else{
        [sectionTitles addObject:localTime];
        sections[localTime] = @1;
    }
    
    [messageTableView reloadData];
    [self scrollBottomOfTableView:YES];
    
}


#pragma mark
#pragma mark Chat Notifications

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    QBChatMessage *message = notification.userInfo[kMessage];
    if(message.senderID != self.dialog.recipientID){
        return;
    }
    
    // save message
    NSString *day = [dateFormatter stringFromDate:message.datetime];
    if( sections[day] )
        sections[day] = @([sections[day] integerValue] + 1);
    else{
        [sectionTitles addObject:day];
        sections[day] = @1;
    }
    
    [messages addObject:message];
    
    // Reload table
    [messageTableView reloadData];
    [self scrollBottomOfTableView:YES];
    
    [QBChat markMessagesAsRead:nil dialogID:self.dialog.ID delegate:nil];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(QBResult *)result
{
    [self hideProgress];
    [messageTableView.infiniteScrollingView stopAnimating];
    [messageTableView.pullToRefreshView stopAnimating];
    if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *msgs = res.messages;
        if(msgs.count > 0){
            
            if( pageNo == 0 ){
                [messages removeAllObjects];
                [sections removeAllObjects];
                [sectionTitles removeAllObjects];
            }
            
            for(QBChatAbstractMessage *msg in msgs){
                NSString *day = [dateFormatter stringFromDate:msg.datetime];
                if( sections[day] )
                    sections[day] = @([sections[day] integerValue] + 1);
                else {
                    [sectionTitles insertObject:day atIndex:0];
                    sections[day] = @1;
                }
                
                [messages insertObject:msg atIndex:0];
            }
            
            [messageTableView reloadData];
            
            if( pageNo == 0)
                [self scrollBottomOfTableView:NO];
            else {
                if( loadedSections < sectionTitles.count )
                    [messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionTitles.count - loadedSections]
                                            atScrollPosition: UITableViewScrollPositionMiddle
                                                    animated: NO];
                else if( loadedRows < messages.count )
                    [messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count - loadedRows inSection:0]
                                            atScrollPosition: UITableViewScrollPositionMiddle
                                                    animated: NO];
                
            }
        }
    }
}

#pragma mark - 
#pragma mark Navigation
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
