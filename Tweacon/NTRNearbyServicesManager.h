//
//  NTRNearbyServicesManager.h
//  Tweacon
//
//  Created by Natasha Murashev on 4/9/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

@interface NTRNearbyServicesManager : NSObject

+ (instancetype)sharedManager;

@property (strong, nonatomic, readonly) NSMutableArray *nearbyUsers;

- (void)start;
- (void)advertiseUser;
- (void)browseForUsers;

@end
