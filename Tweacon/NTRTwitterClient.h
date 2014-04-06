//
//  NTRTwitterClient.h
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

@class ACAccount;
#import "NTRConstants+TwitterClientExtensions.h"

@interface NTRTwitterClient : NSObject

+ (void)loginUserWithAccount:(ACAccount *)twitterAccount;
+ (void)loginUserWithAuthId:(NSString *)authId userName:(NSString *)userName;

@end
