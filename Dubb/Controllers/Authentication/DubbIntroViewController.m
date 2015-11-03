//
//  DubbIntroViewController.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbIntroViewController.h"
#import "AppDelegate.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DubbIntroViewController (){
    
    __weak IBOutlet UIPageControl *pageControl;
}
@property (strong, nonatomic) IBOutlet UIView *movieView;
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) AVPlayer *avplayer;
@property (strong, nonatomic) IBOutlet UIView *blackView;

@end

@implementation DubbIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *moviePath = [bundle pathForResource:@"welcome_video" ofType:@"mp4"];
//    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
//    
//    
//    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
//    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
//    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
//    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
//    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    [avPlayerLayer setFrame:self.view.frame];
//    [self.movieView.layer addSublayer:avPlayerLayer];
//    
//    //Not affecting background music playing
//    NSError *sessionError = nil;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
//    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
//    
//    [self.avplayer seekToTime:kCMTimeZero];
//    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
//    __block AVPlayer* blockPlayer = self.avplayer;
//    __block id obs;
//    __block UIView *blockView = self.blackView;
//    
//    // Setup boundary time observer to trigger when audio really begins,
//    // specifically after 1/3 of a second playback
//    obs = [self.avplayer addBoundaryTimeObserverForTimes:
//           @[[NSValue valueWithCMTime:CMTimeMake(1, 3)]]
//                                            queue:NULL
//                                       usingBlock:^{
//                                           
//                                           blockView.hidden = YES;
//                                           // Remove the boundary time observer
//                                           [blockPlayer removeTimeObserver:obs];
//                                       }];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[self.avplayer currentItem]];
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.gradientView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x030303) CGColor], (id)[[UIColor clearColor] CGColor], (id)[UIColorFromRGB(0x030303) CGColor],nil];
//    [self.gradientView.layer insertSublayer:gradient atIndex:0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id loggedUser = [defaults objectForKey:@"DubbUser"];
    if( loggedUser ){
        [self showProgress:@"Logging in..."];
        [User initialize: (NSDictionary*)loggedUser];
        [self loginToQuickBlox];
    }
}
//- (void)playerItemDidReachEnd:(NSNotification *)notification {
//    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
//}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.avplayer play];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.avplayer pause];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pageControl setCurrentPage:(int) scrollView.contentOffset.x / scrollView.frame.size.width];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
