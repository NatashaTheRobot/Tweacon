//
//  NTRTweaconTableViewCell.h
//  Tweacon
//
//  Created by Natasha Murashev on 4/20/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

@class NTRUser;

@interface NTRTweaconTableViewCell : UITableViewCell

- (void)configureWithUserData:(NTRUser *)userData;

@end
