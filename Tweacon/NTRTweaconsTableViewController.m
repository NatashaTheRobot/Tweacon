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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    NTRUser *user = self.nearbyUsers[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    cell.detailTextLabel.text = user.profileDescription;
    [cell.imageView setImageWithURL:[NSURL URLWithString:user.imageURL]
                   placeholderImage:[UIImage imageNamed:@"placeholder"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
    }];
    
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
    self.nearbyUsers = [NTRNearbyServicesManager sharedManager].nearbyUsers;
    [self.tableView reloadData];
}

- (void)onNearbyUserRemoved
{
    self.nearbyUsers = [NTRNearbyServicesManager sharedManager].nearbyUsers;
    [self.tableView reloadData];
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