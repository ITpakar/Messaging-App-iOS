//
//  DubbChatCell.m
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbChatCell.h"
#import "AsyncImageView.h"
#import "DubbImageBrowser.h"
#import "DubbOverlayProgressView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "DubbRootViewController.h"

@interface DubbChatCell(){
    AsyncImageView *profileImageView;
    UILabel *lblTime;
    UIImageView *bubbleImageView;
    
    UIView *containerView;
    UITextView *messageTextView;
    UIImageView *thumbnailView;
    MPMoviePlayerViewController *videoPlayer;
    DubbOverlayProgressView *progressView;
    UIButton *btnPlayVideo;
    BOOL sentMessage;
    
    NSString *contentType;
    NSTimer *timer;
    CGFloat transferStatus;
}

@end

#define profileImageSize 50

@implementation DubbChatCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews{
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    
    
    ////////////////     Profile Image   //////////////////////////
    if( sentMessage ) //Sender
    {
        [profileImageView setFrame:CGRectMake(width-8-profileImageSize, 10, profileImageSize, profileImageSize)];
        self.profileImage = [User currentUser].profileImage;
    } else {
        [profileImageView setFrame:CGRectMake(8, 10, profileImageSize, profileImageSize)];
    }
    
    
    ////////////////     Bubble Image   //////////////////////////
    if(sentMessage){
        [bubbleImageView setFrame:CGRectMake(20, 10, width - profileImageSize - 40, height - 20)];
    } else {
        [bubbleImageView setFrame:CGRectMake(70, 10, width - profileImageSize - 40, height - 20)];
    }
    
    ////////////////     Container   //////////////////////////
    if( sentMessage )
        [containerView setFrame:CGRectMake(32 , 20, width - profileImageSize - 80, height - 50)];
    else
        [containerView setFrame:CGRectMake(92 , 20, width - profileImageSize - 80, height - 50)];
   
    
    if( contentType ){
        [thumbnailView setFrame:containerView.bounds];
        [progressView setFrame:thumbnailView.bounds];
        [btnPlayVideo setFrame:containerView.bounds];
    } else {
        [messageTextView setFrame:containerView.bounds];
    }
    
    [lblTime setFrame:CGRectMake(bubbleImageView.frame.size.width + bubbleImageView.frame.origin.x - 80 - sentMessage*10, bubbleImageView.frame.origin.y + bubbleImageView.frame.size.height - 15, 70, 12)];
}

-(void)setup{
    if(!sentMessage){
        if( self.profileImage == nil )
           [profileImageView startAnimating];
        else
            profileImageView.image = self.profileImage;
    } else {
        profileImageView.image  = [User currentUser].profileImage;
    }
}

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            Message:(QBChatMessage*) message ProfileImage:(UIImage*)image{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self){
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        self.message = message;
        self.profileImage = image;
        contentType = self.message.customParameters[@"type"];
        
        sentMessage = self.message.senderID == [User currentUser].chatUser.ID;
        
        ////////////////     Profile Image   //////////////////////////
        
        profileImageView = [[AsyncImageView alloc] init];
        profileImageView.showActivityIndicator = YES;
        
        if( sentMessage ) //Sender
        {
            
        }
        
        profileImageView.activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = profileImageSize/2.0f;
        
        [self.contentView addSubview:profileImageView];
        
        
        ////////////////     Bubble Image   //////////////////////////
        
        
        bubbleImageView = [[UIImageView alloc] init];
        UIImage *bubbleImage;
        if(sentMessage){
            bubbleImage = [UIImage imageNamed:@"sender_bubble.png"];
        } else {
            bubbleImage = [UIImage imageNamed:@"receiver_bubble.png"];
        }
        UIImage *cellBGImage = [bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(40, 25, 15, 25) resizingMode:UIImageResizingModeStretch];
        bubbleImageView.image = cellBGImage;
        
        [self.contentView addSubview:bubbleImageView];
        
        ////////////////   Container   /////////////////////
        containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor clearColor];
        containerView.layer.masksToBounds = YES;
        containerView.layer.cornerRadius = 5.0f;
        containerView.userInteractionEnabled = YES;
    
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onContentClicked)];
        [containerView addGestureRecognizer:tapGesture];
        
        [self.contentView addSubview:containerView];
        
        //////////    Video/Picture/Message   ///////////
        
        messageTextView = [[UITextView alloc] init];
        messageTextView.editable =  NO;
        [messageTextView setFont:[UIFont systemFontOfSize:14]];
        messageTextView.backgroundColor = [UIColor clearColor];
        
        if( contentType ){
            
            thumbnailView = [[UIImageView alloc] init];

            if( self.message.customParameters[@"transfer"]){
                thumbnailView.image = self.message.customParameters[@"thumb"];
                _isTransferred = YES;
                if( [contentType isEqualToString:@"Video"] )
                    videoPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL: self.message.customParameters[@"videoURL"]];
                
            } else
                thumbnailView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            
            progressView = [[DubbOverlayProgressView alloc] init];
            
            [thumbnailView addSubview:progressView];
            [containerView addSubview:thumbnailView];
            
            if( [contentType isEqualToString:@"Video"] ){
                btnPlayVideo = [[UIButton alloc] init];
                btnPlayVideo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
                [btnPlayVideo setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
                [btnPlayVideo addTarget:self action:@selector(onContentClicked) forControlEvents:UIControlEventTouchUpInside];
                [containerView addSubview:btnPlayVideo];
            }
            
            if( sentMessage && self.message.customParameters[@"transfer"] )
                [self uploadAttachment];
            else
                [self downloadAttachment];
            
        } else {
            if( sentMessage )
                messageTextView.textColor = [UIColor colorWithRed:43/255.0f green:94/255.0f blue:124/255.0f alpha:1.0f];
            else
                messageTextView.textColor = [UIColor blackColor];
            
            messageTextView.text = self.message.text;
            [containerView addSubview:messageTextView];
        }
        
        lblTime = [[UILabel alloc] init];
        
        [lblTime setFont:[UIFont systemFontOfSize:10]];
        [lblTime setTextAlignment:NSTextAlignmentRight];
        
        if( sentMessage )
            lblTime.textColor = [UIColor colorWithRed:43/255.0f green:94/255.0f blue:124/255.0f alpha:1.0f];
        else
            lblTime.textColor = [UIColor grayColor];

        static NSDateFormatter *dateFormatter;
        if( dateFormatter == nil ){
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setDateFormat: @"hh:mm a"];
        }
        
        lblTime.text = [dateFormatter stringFromDate:self.message.datetime];
        
        [self.contentView addSubview:lblTime];
    }
    return self;
}

-(void) hideProgressOverlay{
    [progressView displayOperationDidFinishAnimation];
    double delayInSeconds = progressView.stateChangeAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        progressView.progress = 0;
        progressView.hidden = YES;
    });
}

-(void) uploadAttachment{
    
    [progressView displayOperationWillTriggerAnimation];
    double delayInSeconds = progressView.stateChangeAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    });
    
    NSString *file_content_type;
    if( [contentType isEqualToString:@"Photo"] )
        file_content_type = @"image/jpeg";
    else
        file_content_type = @"video/quicktime";
    
    NSString *file_name = [NSString stringWithFormat:@"%lu.%lu.jpg", (long)self.message.senderID, (long)[[NSDate date] timeIntervalSince1970] * 1000];
    

    [QBRequest TUploadFile:self.message.customParameters[@"attachment"] fileName:file_name contentType:file_content_type isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
        NSString *url = [blob publicUrl];
        
        //if( [contentType isEqualToString:@"Photo"] )
        [[SDImageCache sharedImageCache] storeImage:self.message.customParameters[@"thumb"] forKey:url];
        
        [self.message.customParameters removeObjectForKey:@"attachment"];
        [self.message.customParameters removeObjectForKey:@"transfer"];
        [self.message.customParameters removeObjectForKey:@"thumb"];
        [self.message.customParameters removeObjectForKey:@"videoURL"];
        
        /*UIImage *image = self.message.customParameters[@"thumb"];
        CGFloat width = 50.0f, height = image.size.height / image.size.width * 50;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *thumb = UIImageJPEGRepresentation(image, 0.7);
        
        [self.message.customParameters setObject:thumb forKey:@"thumb"];*/
        
        QBChatMessage *newMsg = [[QBChatMessage alloc] init];
        newMsg.text = self.message.text;
        newMsg.senderID = self.message.senderID;
        newMsg.recipientID = self.message.recipientID;
        newMsg.customParameters = [NSMutableDictionary dictionaryWithDictionary: self.message.customParameters];
        
        QBChatAttachment *attachment = QBChatAttachment.new;
        attachment.type = contentType;
        attachment.url = url;
        newMsg.attachments = @[attachment];
        
        [[ChatService instance] sendMessage:newMsg];
        [self hideProgressOverlay];
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        transferStatus = status.percentOfCompletion;
    } errorBlock:^(QBResponse *response) {
        if([self.message.customParameters[@"type"] isEqualToString:@"Video"])
           [btnPlayVideo setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
        
        [self hideProgressOverlay];
    }];
}


- (void)updateProgress
{
    CGFloat progress = progressView.progress + 0.01;
    if (progress >= 1) {
        [timer invalidate];
        [progressView displayOperationDidFinishAnimation];
        double delayInSeconds = progressView.stateChangeAnimationDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            progressView.progress = 0.;
            progressView.hidden = YES;
        });
    } else if(progress <= transferStatus ) {
        progressView.progress = progress;
    }
}



-(void) downloadAttachment{
    
    if( self.message.attachments.count < 1 ) return;
    
    //Check Cache
    QBChatAttachment *attachment = self.message.attachments[0];
    
    if( [contentType isEqualToString:@"Video"] ){
        videoPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:attachment.url]];
        [videoPlayer.moviePlayer setShouldAutoplay:NO];
    }
    
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:attachment.url done:^(UIImage *image, SDImageCacheType cacheType) {
        if( image != nil){
            _isTransferred = YES;
            thumbnailView.image = image;
            progressView.hidden = YES;
        } else {
            [self downloadAttachmentFromServer];
        }
    }];
}

-(void) downloadAttachmentFromServer{
    
    QBChatAttachment *attachment = self.message.attachments[0];
    
    [progressView displayOperationWillTriggerAnimation];
    double delayInSeconds = progressView.stateChangeAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    });
    
    if( [contentType isEqualToString:@"Photo"] ){
        
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL: [NSURL URLWithString:attachment.url]
                                                            options:0
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             transferStatus = receivedSize/expectedSize;
         }
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             [self hideProgressOverlay];
             if (image && finished)
             {
                 _isTransferred = YES;
                 thumbnailView.image = image;
                 [[SDImageCache sharedImageCache] storeImage:image forKey:attachment.url];
             }
         }];
        
        
    } else {
        
        videoPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:attachment.url]];
        [videoPlayer.moviePlayer setShouldAutoplay:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onThumbnailExtracted:)
                                                     name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                                   object:videoPlayer.moviePlayer];
        
        [videoPlayer.moviePlayer requestThumbnailImagesAtTimes:@[@0.2f] timeOption:MPMovieTimeOptionExact];
        transferStatus = 0.9;
    }
}

-(void)onThumbnailExtracted : (NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    UIImage *image = [userInfo valueForKey:MPMoviePlayerThumbnailImageKey];
    thumbnailView.image = image;
    
    QBChatAttachment *attachment = self.message.attachments[0];
    [[SDImageCache sharedImageCache] storeImage:image forKey:attachment.url];
    
    transferStatus = 1.0f;
    [self hideProgressOverlay];
    _isTransferred = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:videoPlayer.moviePlayer];
}

-(void) onContentClicked{
    if( !_isTransferred ) return;
    
    if( [contentType isEqualToString:@"Video"] ){
        
        [[NSNotificationCenter defaultCenter] removeObserver:videoPlayer
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:videoPlayer.moviePlayer];
        
        // Register this class as an observer instead
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:videoPlayer.moviePlayer];
        
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        DubbRootViewController *rootVC = (DubbRootViewController*)app.window.rootViewController;
        UINavigationController *navController = (UINavigationController *)rootVC.contentViewController;
        
        videoPlayer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [navController presentViewController:videoPlayer animated:YES completion:nil];
        
        [videoPlayer.moviePlayer prepareToPlay];
        [videoPlayer.moviePlayer play];
        
    } else if( [contentType isEqualToString:@"Photo"]) {
        [DubbImageBrowser showImage:thumbnailView];
    }
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    // Obtain the reason why the movie playback finished
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        // Dismiss the view controller
        [videoPlayer dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
