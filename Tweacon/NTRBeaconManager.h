//
//  NTRBeaconManager.h
//  Tweacon
//
//  Created by Natasha Murashev on 4/7/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

@interface NTRBeaconManager : NSObject

+ (instancetype)sharedManager;

- (void)transmitUserBeacon;

@end
