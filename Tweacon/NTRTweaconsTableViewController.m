//
//  NTRTweaconsTableViewController.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/10/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRTweaconsTableViewController.h"
#import "NTRNearbyServicesManager.h"
#import "NTRUser.h"
#import "NTRTwitterWebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NTRTweaconTableViewCell.h"

@interface NTRTweaconsTableViewController ()

@property (strong, nonatomic) NSArray *nearbyUsers;

@end

@implementation NTRTweaconsTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Searching for Tweacons..." maskType:SVProgressHUDMaskTypeGradient];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[NTRTwitterWebViewController class]]) {
        NTRTwitterWebViewController *twitterWebViewController = segue.destinationViewController;
        NSIndexPath *indexPathForSelectedUser = [self.tableView indexPathForSelectedRow];
        NTRUser *selectedUser = self.nearbyUsers[indexPathForSelectedUser.row];
        twitterWebViewController.screenName = selectedUser.screenName;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearbyUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTRTweaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NTRTweaconTableViewCell class]) forIndexPath:indexPath];
    
    NTRUser *user = self.nearbyUsers[indexPath.row];
    [cell configureWithUserData:user];
    
    return cell;
}

#pragma mark - Private Configurations Methods

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNearbyUserAdded) name:NTRNotificationMultipeerConnectivityUserAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNearbyUserRemoved) name:NTRNotificationMultipeerConnectivityUserRemoved object:nil];
}

- (void)onNearbyUserAdded
{
    [SVProgressHUD dismiss];
    self.nearbyUsers = [NTRNearbyServicesManager sharedManager].nearbyUsers;
    [self.tableView reloadData];
}

- (void)onNearbyUserRemoved
{
    self.nearbyUsers = [NTRNearbyServicesManager sharedManager].nearbyUsers;
    [self.tableView reloadData];
    if ([self.nearbyUsers count] == 0) {
        [SVProgressHUD showWithStatus:@"Searching for Tweacons..." maskType:SVProgressHUDMaskTypeGradient];
    }
}

#pragma mark - Setter / Getter Overrides

- (NSArray *)nearbyUsers
{
    if (!_nearbyUsers) {
        self.nearbyUsers = [NTRNearbyServicesManager sharedManager].nearbyUsers;
    }
    return _nearbyUsers;
}

@end
