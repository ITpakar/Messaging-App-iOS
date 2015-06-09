//
//  DubbServiceAreaViewController.h
//  Dubb
//
//  Created by andikabijaya on 3/26/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import "SelectedLocation.h"
#import "IQDropDownTextField.h"
#import <UIKit/UIKit.h>

@protocol DubbServiceAreaViewControllerDelegate <NSObject>
@required
- (void) completedWithRadius:(NSString*)radius WithLocation:(SelectedLocation *)location;
@end


@interface DubbServiceAreaViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *locationContainerView;
@property (strong, nonatomic) IBOutlet UIView *radiusContainerView;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *radiusTextField;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) id<DubbServiceAreaViewControllerDelegate> delegate;
@property NSMutableArray *pastSearchResults;
@property NSMutableArray *pastSearchWords;
@property NSMutableArray *localSearchQueries;
@property NSTimer *autoCompleteTimer;
@property NSString *substring;
@property CLLocationManager *locationManager;
@property NSString *radius;
@property SelectedLocation *selectedLocation;
@property NSString *titleString;
@end
