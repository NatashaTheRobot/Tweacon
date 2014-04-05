//
//  NTRUser.h
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

@interface NTRUser : PFUser <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;

- (void)configureWithData:(NSDictionary *)data;

@end
