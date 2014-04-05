//
//  NTRUser.m
//  Tweacon
//
//  Created by Natasha Murashev on 4/5/14.
//  Copyright (c) 2014 NatashaTheRobot. All rights reserved.
//

#import "NTRUser.h"

@interface NTRUser ()

@end

@implementation NTRUser

@dynamic name;
@dynamic imageURL;
@dynamic profileDescription;

- (void)configureWithData:(NSDictionary *)data
{
    self.username = data[@"screen_name"];
    self.name= data[@"name"];
    self.profileDescription = data[@"description"];
    self.imageURL = [data[@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
}

@end
