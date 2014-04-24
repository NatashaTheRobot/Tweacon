//
//  NTRNearbyServicesManager.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/9/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRNearbyServicesManager.h"
@import MultipeerConnectivity;
#import "NTRUser.h"

@interface NTRNearbyServicesManager () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCSession *session;

@property (weak, nonatomic)   NTRUser *user;
@property (strong, nonatomic) MCPeerID *peerId;

@property (strong, nonatomic, readwrite) NSMutableArray *nearbyUsers;

@end

@implementation NTRNearbyServicesManager

static NTRNearbyServicesManager *nearbyServicesManager;

+ (instancetype)sharedManager
{
    if (!nearbyServicesManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            nearbyServicesManager = [[NTRNearbyServicesManager alloc] init];
        });
        
    }
    
    return nearbyServicesManager;
}

- (void)start
{
    [self advertiseUser];
    [self browseForUsers];
}

- (void)clear
{
    [self.nearbyUsers removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationMultipeerConnectivityUserRemoved object:nil];
}

#pragma mark - Private Methods

- (void)advertiseUser
{
    if (self.user) {
        
        NSDictionary *discoveryInfo = @{@"userId" : self.user.objectId,
                                        @"screenName" : self.user.screenName,
                                        @"name" : self.user.name,
                                        @"imageURL" : self.user.imageURL};
        
        NSMutableDictionary *additionalDiscoveryInfo = [NSMutableDictionary dictionaryWithDictionary:discoveryInfo];
        if (self.user.backgroundImageURL) {
            additionalDiscoveryInfo[@"backgroundImageURL"] = self.user.backgroundImageURL;
        }
        
        if (self.user.profileImageBackgroundURL) {
            additionalDiscoveryInfo[@"profileImageBackgroundURL"] = self.user.profileImageBackgroundURL;
        }
        
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId
                                                            discoveryInfo:[additionalDiscoveryInfo copy] serviceType:@"Tweacon"];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
    }
}

- (void)browseForUsers
{
    NTRUser *user = [NTRUser currentUser];
    MCPeerID *browserId = [[MCPeerID alloc] initWithDisplayName:user.screenName];
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:browserId serviceType:@"Tweacon"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}

#pragma mark - MCNearbyAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

#pragma mark - MCNearbyBrowerDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"screenName = %@", peerID.displayName];
    
    NSArray *nearbyUsers = [self.nearbyUsers filteredArrayUsingPredicate:filter];
    NTRUser *nearbyUser;
    if ([nearbyUsers count] > 0) {
       nearbyUser = nearbyUsers[0];
    }
    
    BOOL isSameAsUser = [peerID.displayName isEqualToString:self.user.screenName];
    BOOL isSameAsExistingNearbyUser = [peerID.displayName isEqualToString:nearbyUser.screenName];
    
    if (!isSameAsUser && !isSameAsExistingNearbyUser)
    {
        NTRUser *user = [NTRUser new];
        user.objectId = info[@"userId"];
        user.screenName = info[@"screenName"];
        user.name = info[@"name"];
        user.imageURL = info[@"imageURL"];
        user.backgroundImageURL = info[@"backgroundImageURL"];
        user.profileImageBackgroundURL = info[@"profileImageBackgroundURL"];
        [self.nearbyUsers addObject:user];
        [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationMultipeerConnectivityUserAdded object:nil];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"screenName = %@", peerID.displayName];
    NSArray *nearbyUsers = [self.nearbyUsers filteredArrayUsingPredicate:filter];
    if ([nearbyUsers count] > 0) {
        [self.nearbyUsers removeObject:nearbyUsers[0]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NTRNotificationMultipeerConnectivityUserRemoved object:nil];
    }
}

#pragma mark - Setter / Getter Overrides

- (NTRUser *)user
{
    if (!_user) {
        self.user = [NTRUser currentUser];
    }
    return _user;
}

- (MCPeerID *)peerId
{
    if (!_peerId) {
        self.peerId = [[MCPeerID alloc] initWithDisplayName:self.user.screenName];
    }
    return _peerId;
}

- (NSMutableArray *)nearbyUsers
{
    if (!_nearbyUsers) {
        self.nearbyUsers = [NSMutableArray arrayWithCapacity:10];
    }
    return _nearbyUsers;
}

@end
